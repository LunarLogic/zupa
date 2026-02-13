import TableRow from '@tiptap/extension-table-row'

export default TableRow.extend({
  addAttributes() {
    return {
      ...this.parent?.(),
      id: {
        default: null,
        parseHTML: element => element.getAttribute('id'),
        renderHTML: attributes => {
          return attributes.id ? { id: attributes.id } : {}
        },
      },
      class: {
        default: null,
        parseHTML: element => element.getAttribute('class'),
        renderHTML: attributes => {
          return attributes.class ? { class: attributes.class } : {}
        },
      },
    }
  },
})
