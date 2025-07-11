import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["testResponse"]

  async generateRandom() {
    const button = event.target
    this.animateDots(button, "Generating")
    
    
    const response = await fetch("/personas/generate_random", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      const subscription = await window.ActionCable.consumer.subscriptions.create(
        { channel: "PersonaGenerationChannel", job_id: data.job_id },
        {
          received: (data) => {
            this.handleGenerationComplete(data, button, subscription)
          }
        }
      )
    }
  }

  handleGenerationComplete(data, button, subscription) {
    if (data.status === "completed") {
      document.querySelector('#persona_name').value = data.name
      document.querySelector('#persona_description').value = data.description
    } else if (data.status === "error") {
      console.error("Generation failed:", data.error)
    }
    
    this.stopDots(button, "🎲 Generate Random Persona")
    subscription.unsubscribe()
  }

  async testPersona() {
    const button = event.target
    const description = document.querySelector('#persona_description').value
    
    if (!description.trim()) return
    
    button.disabled = true
    button.textContent = "Testing..."
    
    const response = await fetch("/personas/test", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ description: description })
    })
    
    if (response.ok) {
      const data = await response.json()
      this.testResponseTarget.classList.remove('d-none')
      this.testResponseTarget.querySelector('.alert').textContent = data.response
    }
    
    button.disabled = false
    button.textContent = "🧪 Test Me"
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