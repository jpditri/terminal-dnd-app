# frozen_string_literal: true

module Api
  module V1
    class TerminalSessionsController < BaseController
      before_action :set_terminal_session, only: %i[show update message state history]

      def create
        @terminal_session = current_user.terminal_sessions.create!(terminal_session_params)
        render json: @terminal_session, status: :created
      end

      def show
        render json: @terminal_session
      end

      def update
        @terminal_session.update!(terminal_session_params)
        render json: @terminal_session
      end

      def message
        input = params[:message] || params[:input]
        return render json: { error: 'No message provided' }, status: :bad_request if input.blank?

        @terminal_session.add_to_history(input) if @terminal_session.respond_to?(:add_to_history)
        render json: { status: 'received', message: input }
      end

      def state
        render json: {
          session_id: @terminal_session.id,
          mode: @terminal_session.mode,
          active: @terminal_session.active
        }
      end

      def history
        entries = @terminal_session.narrative_outputs.order(created_at: :desc).limit(50)
        render json: entries
      end

      private

      def set_terminal_session
        @terminal_session = current_user.terminal_sessions.find(params[:id])
      end

      def terminal_session_params
        params.require(:terminal_session).permit(:title, :mode, :active)
      end
    end
  end
end
