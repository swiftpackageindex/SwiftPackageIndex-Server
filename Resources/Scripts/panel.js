// Copyright 2020-2021 Dave Verwer, Sven A. Schmidt, and other contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

export class SPIPanel {
  constructor() {
    document.addEventListener('turbo:load', () => {
      const panelElements = document.querySelectorAll('.panel')
      panelElements.forEach((panelElement) => {
        // Remove any old close buttons if they exist.
        const oldCloseButtonElement = panelElement.querySelector('.close')
        if (oldCloseButtonElement) oldCloseButtonElement.remove()

        const closeButtonElement = document.createElement('button')
        panelElement.insertBefore(closeButtonElement, panelElement.firstChild)

        closeButtonElement.innerHTML = '&times;'
        closeButtonElement.classList.add('close')
        closeButtonElement.addEventListener('click', (event) => {
          panelElement.classList.add('hidden')
          event.preventDefault()
        })
      })
    })
  }
}
