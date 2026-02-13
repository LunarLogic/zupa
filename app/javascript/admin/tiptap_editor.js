import { Editor } from '@tiptap/core'
import StarterKit from '@tiptap/starter-kit'
import { debounce } from 'lodash'
import Mustache from "mustache";
import TableCell from '@tiptap/extension-table-cell'
import TableHeader from '@tiptap/extension-table-header'
import BubbleMenu from '@tiptap/extension-bubble-menu'
import TableWithClass from './table_with_class'
import TableRowWithIdAndClass from './table_row_with_id_and_class'
import {
  mustachify, demustachify, addGroupRowId, markGroupTable, markRegularTable
} from './groups_table'

function save(content, saveUrl) {
  updateStatus("💾 Saving...");

  // Determine the param key based on the URL
  const paramKey = saveUrl.includes('preparation_templates')
    ? 'preparation_template'
    : 'trip';

  const bodyKey = paramKey === 'preparation_template' ? 'content_html' : 'preparations_html';

  fetch(saveUrl, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
    },
    body: JSON.stringify({
      [paramKey]: { [bodyKey]: content }
    }),
  }).then(() => {
    updateStatus("✅ Saved just now");
  }).catch(() => {
    updateStatus("❌ Error saving");
  });
}

function createDebouncedSave(saveUrl) {
  return debounce((html) => {
    const mustachified = mustachify(html);
    save(mustachified, saveUrl);

    const trip = getTripData();
    if (trip) {
      updatePreview(mustachified, trip);
    }
  }, 1000);
}

function updateStatus(text) {
  const status = document.getElementById("editor-status");
  if (status) status.textContent = text;
}

function getTripData() {
  const el = document.getElementById("trip-json");
  if (!el) return null;

  try {
    return JSON.parse(el.textContent);
  } catch (e) {
    console.error("Failed to parse trip JSON", e);
    return { groups: [], organiser: "", date: "" };
  }
}

function getGroupsData() {
  const el = document.getElementById("groups-json");
  if (!el) return { groups: [] };

  try {
    const groups = JSON.parse(el.textContent);
    return { groups };
  } catch (e) {
    console.error("Failed to parse groups JSON", e);
    return { groups: [] };
  }
}

function updatePreview(templateString, data) {
  const preview = document.getElementById('rendered-preview')
  if (!preview) return

  try {
    const rendered = Mustache.render(templateString, data)
    preview.innerHTML = rendered
  } catch (error) {
    preview.innerHTML = `<pre style="color:red;">${error.message}</pre>`
  }
}

function setupEditor(element, content, saveUrl) {
  const bubbleMenuElement = createBubbleMenuElement()
  const debouncedSave = createDebouncedSave(saveUrl)

  const editor = new Editor({
    element: element,
    extensions: [
      StarterKit.configure({
        history: false,
      }),
      BubbleMenu.configure({
        element: bubbleMenuElement,
        tippyOptions: {
          placement: 'top',
        },
      }),
      TableWithClass.configure({ resizable: true }),
      TableRowWithIdAndClass,
      TableHeader,
      TableCell,
    ],
    content: content,
    autofocus: true,
    editable: true,
    injectCSS: false,
    onUpdate: ({ editor }) => {
      debouncedSave(editor.getHTML());
    }
  })

  attachBubbleMenuListeners(bubbleMenuElement, editor)
  createTableToolbar(editor)

  return editor
}

function initializeEditor() {
  const element = document.querySelector('.element')
  if (!element) return

  const saveUrl = element.dataset.saveUrl
  const tripId = element.dataset.tripId
  const templateId = element.dataset.templateId

  // Template editor mode (PreparationTemplate admin)
  if (templateId && saveUrl) {
    const contentInput = document.querySelector('input[name="preparation_template[content_html]"]')
    if (!contentInput) return

    const raw = contentInput.value
    const content = demustachify(raw)
    setupEditor(element, content, saveUrl)
    return
  }

  // Trip editor mode — initialized lazily via "Edytuj" button
  if (tripId && !saveUrl) {
    // Old-style direct initialization (backward compat)
    const contentElement = document.querySelector('input[name="trip[preparations_html]"]');
    if (!contentElement) return

    const raw = contentElement.value
    const content = demustachify(raw)
    const url = `/admin/trips/${tripId}/update_preparations`

    const editor = setupEditor(element, content, url)
    const trip = getTripData()
    if (trip) updatePreview(raw, trip)
    return
  }

  // Trip editor with explicit save URL (new mode)
  if (tripId && saveUrl) {
    const contentElement = document.querySelector('input[name="trip[preparations_html]"]');
    if (!contentElement) return

    const raw = contentElement.value
    const content = demustachify(raw)

    const editor = setupEditor(element, content, saveUrl)
    const trip = getTripData()
    if (trip) updatePreview(raw, trip)
    return
  }
}

// Expose for lazy initialization from the "Edytuj" button
window.initializeTripEditor = function() {
  const element = document.querySelector('.element')
  if (!element || element.dataset.editorInitialized) return

  element.dataset.editorInitialized = 'true'
  initializeEditor()
}

function createBubbleMenuElement() {
  const menu = document.createElement('div')
  menu.classList.add('bubble-menu')

  const buttons = [
    { id: 'bold', text: 'Bold' },
    { id: 'italic', text: 'Italic' },
  ]

  buttons.forEach(({ id, text }) => {
    const btn = document.createElement('button')
    btn.id = id
    btn.type = 'button'
    btn.innerText = text
    menu.appendChild(btn)
  })

  document.body.appendChild(menu)
  return menu
}

function attachBubbleMenuListeners(menu, editor) {
  menu.querySelector('#bold').addEventListener('click', e => {
    e.preventDefault()
    e.stopPropagation()
    editor.chain().focus().toggleBold().run()
  })

  menu.querySelector('#italic').addEventListener('click', e => {
    e.preventDefault()
    e.stopPropagation()
    editor.chain().focus().toggleItalic().run()
  })
}

function createTableToolbar(editor) {
  const menu = document.createElement('div')
  menu.classList.add('table-toolbar')

  const buttons = [
    {
      id: 'insert-group-table',
      text: 'Wstaw Tabelę',
      command: () => insertGroupTableAndRenderPreview(editor)
    },
    { id: 'add-row', text: 'Wstaw wiersz', command: () => editor.commands.addRowAfter() },
    { id: 'delete-row', text: 'Usuń wiersz', command: () => editor.commands.deleteRow() },
    { id: 'add-column', text: 'Wstaw kolumnę', command: () => editor.commands.addColumnAfter() },
    { id: 'delete-column', text: 'Usuń kolumnę', command: () => editor.commands.deleteColumn() },
  ]

  buttons.forEach(({ id, text, command }) => {
    const btn = document.createElement('button')
    btn.id = id
    btn.type = 'button'
    btn.innerText = text
    btn.addEventListener('click', (e) => {
      e.preventDefault()
      e.stopPropagation()
      editor.chain().focus()
      command()
    })
    menu.appendChild(btn)
  })
  const editorElement = document.querySelector('.element')
  if (editorElement) {
    editorElement.insertBefore(menu, editorElement.firstChild)
  }
}

function addFooterRow(html, columnCount) {
  const cells = Array.from({ length: columnCount })
    .map(() => '<td>&nbsp;</td>')
    .join('');
  const footerRow = `<tr class="group-table-footer">${cells}</tr>`;
  return html.replace(/<\/table>/, `${footerRow}</table>`);
}

function insertGroupTableAndRenderPreview(editor) {
  editor.commands.insertTable({ rows: 2, cols: 2, withHeaderRow: true });
  let html = editor.getHTML();
  html = markGroupTable(html);
  html = addGroupRowId(html);
  html = addFooterRow(html, 2);
  editor.commands.setContent(html, false);
}

// Wire up template selector and action buttons for the trip preparations tab
function initializePreparationControls() {
  const templateSelect = document.getElementById('template-select')
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

  if (templateSelect) {
    templateSelect.addEventListener('change', (e) => {
      const tripId = templateSelect.dataset.tripId
      const templateId = e.target.value

      fetch(`/admin/trips/${tripId}/select_template`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
        },
        body: JSON.stringify({ preparation_template_id: templateId })
      })
      .then(r => r.json())
      .then(data => {
        // Update the hidden input with new content
        const input = document.querySelector('input[name="trip[preparations_html]"]')
        if (input) input.value = data.content_html || ''

        // Update preview
        const trip = getTripData()
        if (trip && data.content_html) {
          updatePreview(data.content_html, trip)
        } else {
          const preview = document.getElementById('rendered-preview')
          if (preview) preview.innerHTML = '<em>Brak treści</em>'
        }

        // Update status
        const status = document.getElementById('template-status')
        if (status) {
          status.textContent = data.template_name
            ? `Używa szablonu: ${data.template_name}`
            : 'Brak szablonu'
        }

        // Update template-dependent button visibility
        const btnUpdate = document.getElementById('btn-update-template')
        const btnReset = document.getElementById('btn-reset-preparations')
        if (btnUpdate) btnUpdate.style.display = templateId ? '' : 'none'
        if (btnReset) btnReset.style.display = templateId ? '' : 'none'
      })
    })
  }

  // Reset preparations (revert to template)
  const btnReset = document.getElementById('btn-reset-preparations')
  if (btnReset) {
    btnReset.addEventListener('click', (e) => {
      e.preventDefault()
      const tripId = btnReset.dataset.tripId

      fetch(`/admin/trips/${tripId}/reset_preparations`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
        }
      })
      .then(r => r.json())
      .then(data => {
        const input = document.querySelector('input[name="trip[preparations_html]"]')
        if (input) input.value = data.content_html || ''

        const trip = getTripData()
        if (trip && data.content_html) updatePreview(data.content_html, trip)

        // Hide editor and show edit button again
        const editorSection = document.getElementById('editor-section')
        if (editorSection) editorSection.style.display = 'none'
        const btnEdit = document.getElementById('btn-edit-preparations')
        if (btnEdit) btnEdit.style.display = ''
      })
    })
  }

  // Update linked template from trip's current HTML
  const btnUpdateTemplate = document.getElementById('btn-update-template')
  if (btnUpdateTemplate) {
    btnUpdateTemplate.addEventListener('click', (e) => {
      e.preventDefault()
      const tripId = btnUpdateTemplate.dataset.tripId

      if (!confirm('Czy na pewno chcesz zaktualizować szablon treścią z tego wyjazdu?')) return

      fetch(`/admin/trips/${tripId}/update_template_from_trip`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
        }
      })
      .then(r => r.json())
      .then(data => {
        if (data.template_name) {
          alert(`Szablon "${data.template_name}" został zaktualizowany.`)
        }
      })
    })
  }

  // Save as new template
  const btnSaveAsTemplate = document.getElementById('btn-save-as-template')
  if (btnSaveAsTemplate) {
    btnSaveAsTemplate.addEventListener('click', (e) => {
      e.preventDefault()
      const tripId = btnSaveAsTemplate.dataset.tripId
      const name = prompt('Nazwa nowego szablonu:')
      if (!name) return

      fetch(`/admin/trips/${tripId}/save_as_template`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
        },
        body: JSON.stringify({ name: name })
      })
      .then(r => r.json())
      .then(data => {
        if (data.template_name) {
          alert(`Utworzono szablon "${data.template_name}".`)
          // Update the template selector
          const select = document.getElementById('template-select')
          if (select) {
            const option = document.createElement('option')
            option.value = data.template_id
            option.textContent = data.template_name
            option.selected = true
            select.appendChild(option)
          }
          // Update status
          const status = document.getElementById('template-status')
          if (status) status.textContent = `Używa szablonu: ${data.template_name}`

          // Hide editor section
          const editorSection = document.getElementById('editor-section')
          if (editorSection) editorSection.style.display = 'none'
          const btnEdit = document.getElementById('btn-edit-preparations')
          if (btnEdit) btnEdit.style.display = ''
        }
      })
    })
  }
}

function tryInitializeTemplateEditor() {
  const templateElement = document.querySelector('.element[data-template-id]')
  if (!templateElement || templateElement.dataset.editorInitialized) return false
  templateElement.dataset.editorInitialized = 'true'
  initializeEditor()
  return true
}

document.addEventListener("DOMContentLoaded", () => {
  setTimeout(() => {
    // Auto-initialize for template editor if the edytor tab is already visible
    tryInitializeTemplateEditor()

    // Listen for Bootstrap tab switches (Trestle uses Bootstrap tabs)
    // The edytor tab content exists in DOM but may not be active on load
    document.addEventListener('shown.bs.tab', () => {
      setTimeout(() => tryInitializeTemplateEditor(), 50)
    })
    // Bootstrap 3 / jQuery event (Trestle may use either)
    if (window.jQuery) {
      window.jQuery(document).on('shown.bs.tab', () => {
        setTimeout(() => tryInitializeTemplateEditor(), 50)
      })
    }

    // For trip preparations tab: only initialize preview, not the editor
    const tripElement = document.querySelector('.element[data-trip-id]')
    if (tripElement) {
      if (tripElement.dataset.saveUrl) {
        const contentElement = document.querySelector('input[name="trip[preparations_html]"]')
        const trip = getTripData()
        if (contentElement && trip && contentElement.value) {
          updatePreview(contentElement.value, trip)
        }
      }
    }

    initializePreparationControls()
  }, 50)
})
