# Pin npm packages by running ./bin/importmap

pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.2/dist/stimulus.js"
pin "@hotwired/stimulus/", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.2/dist/"
pin "application", to: "application.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"