import { application } from "./application"

const controllerFiles = require.context(".", true, /\.js$/)
controllerFiles.keys().forEach((filename) => {
  const controllerName = filename
    .replace("./", "")
    .replace(/_controller\.js$/, "")
  const controller = controllerFiles(filename)
  application.register(controllerName, controller.default)
})
