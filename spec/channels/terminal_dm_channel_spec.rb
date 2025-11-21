# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TerminalDmChannel, type: :channel do
  let(:user) { create(:user) }
  let(:session) { create(:terminal_session, user: user) }

  before do
    stub_connection current_user: user
  end

  describe '#subscribed' do
    it 'successfully subscribes to the channel' do
      subscribe(session_id: session.id)

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_for(session)
    end

    it 'transmits initial state on connection' do
      subscribe(session_id: session.id)

      expect(transmissions.last).to include(
        'type' => 'connected',
        'session_id' => session.id,
        'mode' => session.mode,
        'pending_approvals' => []
      )
    end

    it 'rejects subscription without valid session' do
      subscribe(session_id: 999999)

      expect(subscription).to be_rejected
    end

    it 'rejects subscription for different user session' do
      other_user = create(:user)
      other_session = create(:terminal_session, user: other_user)

      subscribe(session_id: other_session.id)

      expect(subscription).to be_rejected
    end
  end

  describe '#send_message' do
    before { subscribe(session_id: session.id) }

    context 'with mocked AI orchestrator' do
      let(:mock_response) do
        {
          narrative: 'The ancient door creaks open, revealing a dimly lit corridor.',
          tool_results: [],
          pending_approvals: [],
          quick_actions: [
            { label: 'Investigate corridor', action_type: 'search', params: {} },
            { label: 'Light a torch', action_type: 'inventory', params: { item: 'torch' } }
          ],
          state_updates: []
        }
      end

      before do
        allow_any_instance_of(AiDm::Orchestrator).to receive(:process_message)
          .and_return(mock_response)
      end

      it 'processes player message and broadcasts response' do
        perform :send_message, message: 'I open the door'

        expect(transmissions.last).to include(
          'type' => 'dm_response',
          'narrative' => mock_response[:narrative]
        )
      end

      it 'saves message to conversation history' do
        expect {
          perform :send_message, message: 'I search the room'
        }.to change { session.reload.narrative_outputs.count }.by(2)

        narratives = session.narrative_outputs.order(:created_at).last(2)
        expect(narratives[0].content).to eq('I search the room')
        expect(narratives[0].content_type).to eq('player')
        expect(narratives[1].content).to eq(mock_response[:narrative])
        expect(narratives[1].content_type).to eq('dm')
      end

      it 'includes quick actions in response' do
        perform :send_message, message: 'What should I do?'

        response = transmissions.last
        expect(response['quick_actions']).to be_present
        expect(response['quick_actions'].size).to eq(2)
        expect(response['quick_actions'][0]['label']).to eq('Investigate corridor')
      end

      it 'includes pending approvals when present' do
        pending_action = create(:dm_pending_action, terminal_session: session, user: user)

        allow_any_instance_of(AiDm::Orchestrator).to receive(:process_message)
          .and_return(mock_response.merge(pending_approvals: [pending_action]))

        perform :send_message, message: 'I level up my character'

        response = transmissions.last
        expect(response['pending_approvals']).to be_present
      end
    end

    context 'error handling' do
      before do
        allow_any_instance_of(AiDm::Orchestrator).to receive(:process_message)
          .and_raise(StandardError, 'AI service unavailable')
      end

      it 'broadcasts error message on failure' do
        perform :send_message, message: 'Hello'

        expect(transmissions.last).to include(
          'type' => 'error',
          'message' => 'Error processing message: AI service unavailable'
        )
      end
    end
  end

  describe '#roll_dice' do
    before { subscribe(session_id: session.id) }

    it 'executes dice roll and broadcasts result' do
      allow_any_instance_of(AiDm::ToolExecutor).to receive(:execute)
        .and_return({
          success: true,
          message: 'Rolled 1d20: 15',
          total: 15,
          rolls: [15]
        })

      perform :roll_dice, dice: '1d20', purpose: 'Initiative'

      response = transmissions.last
      expect(response['type']).to eq('dice_roll')
      expect(response['result']['message']).to include('Rolled 1d20: 15')
    end
  end

  describe '#approve_action' do
    let(:pending_action) { create(:dm_pending_action, terminal_session: session, user: user) }

    before { subscribe(session_id: session.id) }

    it 'approves pending action and broadcasts result' do
      allow_any_instance_of(AiDm::Orchestrator).to receive(:handle_approval)
        .and_return({
          result: { success: true, message: 'Character leveled up!' },
          follow_up: 'Your character feels stronger.'
        })

      perform :approve_action, action_id: pending_action.id

      response = transmissions.last
      expect(response['type']).to eq('action_approved')
      expect(response['action_id']).to eq(pending_action.id)
    end
  end

  describe '#reject_action' do
    let(:pending_action) { create(:dm_pending_action, terminal_session: session, user: user) }

    before { subscribe(session_id: session.id) }

    it 'rejects pending action and broadcasts result' do
      allow_any_instance_of(AiDm::Orchestrator).to receive(:handle_approval)
        .and_return({
          rejected: true,
          follow_up: 'The character remains unchanged.'
        })

      perform :reject_action, action_id: pending_action.id, reason: 'Not appropriate'

      response = transmissions.last
      expect(response['type']).to eq('action_rejected')
      expect(response['action_id']).to eq(pending_action.id)
    end
  end

  describe '#set_mode' do
    before { subscribe(session_id: session.id) }

    it 'changes session mode and broadcasts update' do
      perform :set_mode, mode: 'combat'

      expect(session.reload.mode).to eq('combat')
      expect(transmissions.last).to include(
        'type' => 'mode_changed',
        'mode' => 'combat'
      )
    end
  end

  describe '#quick_action' do
    before { subscribe(session_id: session.id) }

    it 'processes quick action search' do
      allow_any_instance_of(AiDm::Orchestrator).to receive(:process_message)
        .and_return({
          narrative: 'You search carefully...',
          tool_results: [],
          pending_approvals: [],
          quick_actions: [],
          state_updates: []
        })

      perform :quick_action, action: 'search'

      # Should trigger send_message internally
      expect(transmissions.last['type']).to eq('dm_response')
    end
  end
end
