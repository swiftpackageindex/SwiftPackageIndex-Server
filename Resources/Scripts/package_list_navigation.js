import { KeyCodes } from './keycodes.js'

export class SPIPackageListNavigation {
  constructor() {
    document.addEventListener('DOMContentLoaded', () => {
      this.installDocumentEventHandlers()
    })
  }

  installDocumentEventHandlers() {
    // Only add package list navigation if there is a package list to navigate!
    const packageListElement = document.getElementById('package_list')
    if (!packageListElement) return

    document.addEventListener('keydown', (event) => {
      // If a query field has focus and this is an enter keypress, continue submitting the form.
      const queryElement = document.getElementById('query')
      if (
        queryElement &&
        document.activeElement === queryElement &&
        event.keyCode == KeyCodes.enter
      ) {
        return
      }

      // The document should never respond to the keys we are overriding.
      if (
        event.keyCode == KeyCodes.enter ||
        event.keyCode == KeyCodes.upArrow ||
        event.keyCode == KeyCodes.downArrow
      ) {
        event.preventDefault()
      }

      // Process the keyboard event.
      switch (event.keyCode) {
        case KeyCodes.downArrow: {
          queryElement.blur()
          this.selectNextPackage()
          break
        }
        case KeyCodes.upArrow: {
          queryElement.blur()
          this.selectPreviousPackage()
          break
        }
        case KeyCodes.enter: {
          this.navigateToSelectedPackage()
          break
        }
        case KeyCodes.escape: {
          this.selectedPackageIndex = null
          window.scrollTo(0, 0)
          break
        }
      }

      // Ensure that the list shows the selected item.
      this.updatePackageListSelection()
    })
  }

  selectNextPackage() {
    const packageListElement = document.getElementById('package_list')
    if (!packageListElement) return

    if (typeof this.selectedPackageIndex !== 'number') {
      // If there is no current selection, start at the top of the list.
      this.selectedPackageIndex = 0
    } else {
      // Otherwise, just move down the list, but never beyond the end!
      this.selectedPackageIndex = Math.min(
        this.selectedPackageIndex + 1,
        packageListElement.children.length - 1
      )
    }
  }

  selectPreviousPackage() {
    const packageListElement = document.getElementById('package_list')
    if (!packageListElement) return

    if (typeof this.selectedPackageIndex !== 'number') {
      // If there is no current selection, start at the bottom of the list.
      this.selectedPackageIndex = packageListElement.children.length - 1
    } else {
      // Otherwise, just move up the list, but never beyond the start!
      this.selectedPackageIndex = Math.max(this.selectedPackageIndex - 1, 0)
    }
  }

  navigateToSelectedPackage() {
    const packageListElement = document.getElementById('package_list')
    if (!packageListElement) return

    // Grab the selected list item, find the link inside it, and navigate to it.
    const selectedItem = packageListElement.children[this.selectedPackageIndex]
    if (!selectedItem) return
    const linkElement = selectedItem.querySelector('a')
    if (!linkElement) return
    linkElement.click()
  }

  updatePackageListSelection() {
    const packageListElement = document.getElementById('package_list')
    if (!packageListElement) return

    Array.from(packageListElement.children).forEach((listItem, index) => {
      if (index == this.selectedPackageIndex) {
        // Add the selected class to the selected element.
        listItem.classList.add('selected')

        // Ensure that the element is visible
        listItem.scrollIntoView({ block: 'nearest' })
      } else {
        // Remove the selected class from *every* other item.
        listItem.classList.remove('selected')
      }
    })
  }
}
