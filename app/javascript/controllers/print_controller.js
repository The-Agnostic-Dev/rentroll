import { Controller } from "@hotwired/stimulus"

// Opens the browser print dialog for receipts.
export default class extends Controller {
  print(event) {
    event.preventDefault()
    window.print()
  }
}
