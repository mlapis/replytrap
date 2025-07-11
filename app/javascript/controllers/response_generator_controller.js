import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "button"]

  async generate() {
    // Prevent multiple simultaneous generations
    if (this.buttonTarget.disabled) return
    
    const conversationId = this.buttonTarget.dataset.conversationId
    
    // Show loading state with animated dots
    this.animateDots(this.buttonTarget, "Generating")
    
    try {
      const response = await fetch(`/conversations/${conversationId}/generate_response`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        this.textareaTarget.value = data.response
        this.textareaTarget.focus()
        this.stopDots(this.buttonTarget, "Response already generated")
        this.buttonTarget.disabled = true
      } else {
        alert("Failed to generate response. Please try again.")
        this.stopDots(this.buttonTarget, "Generate Response")
      }
    } catch (error) {
      console.error("Error generating response:", error)
      alert("Failed to generate response. Please try again.")
      this.stopDots(this.buttonTarget, "Generate Response")
    }
  }

  animateDots(button, text) {
    button.disabled = true
    let dots = 0
    button.dotsInterval = setInterval(() => {
      dots = (dots + 1) % 4
      button.textContent = text + '.'.repeat(dots)
    }, 500)
  }

  stopDots(button, text) {
    clearInterval(button.dotsInterval)
    button.disabled = false
    button.textContent = text
  }
}