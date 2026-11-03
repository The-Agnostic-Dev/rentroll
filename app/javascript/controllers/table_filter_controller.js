import { Controller } from "@hotwired/stimulus"

// Narrows a table down to the rows matching what has been typed so far.
// Each row carries its searchable text in data-filter-text.
export default class extends Controller {
  static targets = ["input", "row", "count", "empty"]

  connect() {
    this.filter()
  }

  filter() {
    const query = this.inputTarget.value.trim()
    let shown = 0

    this.rowTargets.forEach((row) => {
      const match = query === "" || row.dataset.filterText.includes(query)
      row.hidden = !match
      if (match) shown++
    })

    if (this.hasCountTarget) this.countTarget.textContent = this.describe(shown)
    if (this.hasEmptyTarget) this.emptyTarget.hidden = shown > 0
  }

  clear() {
    this.inputTarget.value = ""
    this.filter()
    this.inputTarget.focus()
  }

  describe(shown) {
    const total = this.rowTargets.length
    return shown === total ? `${total} tenants` : `${shown} of ${total} tenants`
  }
}
