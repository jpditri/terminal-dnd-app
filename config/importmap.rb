# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js"
pin "@hotwired/turbo", to: "@hotwired--turbo.js"
pin "@rails/actioncable", to: "@rails--actioncable.js"
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js"

# Pin local controllers
pin "controllers/application", to: "controllers/application.js"
pin "controllers/index", to: "controllers/index.js"
pin "controllers/terminal_controller", to: "controllers/terminal_controller.js"
pin "controllers/narrative_box_controller", to: "controllers/narrative_box_controller.js"
pin "controllers/map_canvas_controller", to: "controllers/map_canvas_controller.js"
