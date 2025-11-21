// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.

import { application } from "controllers/application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import TerminalController from "controllers/terminal_controller"
application.register("terminal", TerminalController)

import NarrativeBoxController from "controllers/narrative_box_controller"
application.register("narrative-box", NarrativeBoxController)

import MapCanvasController from "controllers/map_canvas_controller"
application.register("map-canvas", MapCanvasController)
