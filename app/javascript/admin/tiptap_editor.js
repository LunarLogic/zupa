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
  mustachify, demustachify, addGroupRowId, markGroupTable
} from './groups_table'

function save(content, saveUrl) {
  updateStatus("💾 Saving...");

  fetch(saveUrl, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
    },
    body: JSON.stringify({
      preparation_template: { content_html: content }
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
}

// Expose for lazy initialization of template editor (NEW templates without autosave)
window.initializeTemplateEditor = function() {
  const element = document.querySelector('.element')
  if (!element || element.dataset.editorInitialized) return

  element.dataset.editorInitialized = 'true'

  const contentInput = document.querySelector('input[name="preparation_template[content_html]"]')
  if (!contentInput) return

  const raw = contentInput.value
  const content = demustachify(raw)

  // Setup editor without save URL (no autosave for new templates)
  const debouncedPreviewUpdate = debounce((html) => {
    const mustachified = mustachify(html)
    contentInput.value = mustachified

    const trip = getTripData()
    if (trip) {
      updatePreview(mustachified, trip)
    }
  }, 300)

  const bubbleMenuElement = createBubbleMenuElement()
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
      debouncedPreviewUpdate(editor.getHTML());
    }
  })

  attachBubbleMenuListeners(bubbleMenuElement, editor)
  createTableToolbar(editor)

  // Initial preview
  const trip = getTripData()
  if (trip) {
    updatePreview(raw, trip)
  }
}

// Close the template editor, hide the editor section, show the Edytuj button
window.closeTemplateEditor = function() {
  const editorSection = document.getElementById('editor-section')
  if (editorSection) editorSection.style.display = 'none'

  const btnEdit = document.getElementById('btn-edit-template')
  if (btnEdit) btnEdit.style.display = ''
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

// Wire up template selector for the trip preparations tab
function initializePreparationControls() {
  const templateSelect = document.getElementById('template-select')
  if (!templateSelect) return

  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

  templateSelect.addEventListener('change', () => {
    const tripId = templateSelect.dataset.tripId
    const templateId = templateSelect.value

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
      const preview = document.getElementById('rendered-preview')
      if (preview) preview.innerHTML = data.rendered_html || ''
    })
  })
}

function tryInitializeTemplateEditor() {
  const templateElement = document.querySelector('.element[data-template-id]')
  if (!templateElement || templateElement.dataset.editorInitialized) return false
  // Only auto-initialize if the element has a save URL (old autosave flow).
  // New templates without saveUrl are initialized lazily via "Edytuj" button.
  if (!templateElement.dataset.saveUrl) return false
  templateElement.dataset.editorInitialized = 'true'
  initializeEditor()
  return true
}

function initializeOnPageLoad() {
  setTimeout(() => {
    // Auto-initialize for template editor if the edytor tab is already visible
    tryInitializeTemplateEditor()

    // Wire up trip preparations template selector
    initializePreparationControls()
  }, 50)
}

document.addEventListener("DOMContentLoaded", () => {
  initializeOnPageLoad()

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
})
