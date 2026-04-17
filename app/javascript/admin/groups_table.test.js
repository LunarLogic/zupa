import {
  mustachify,
  demustachify,
  addGroupRowId,
  markGroupTable,
  markRegularTable
} from './groups_table'

describe('groups_table utils', () => {
  const baseTable = `
    <table>
      <tbody>
        <tr><th>Header</th></tr>
        <tr><td>Group row</td></tr>
      </tbody>
    </table>
  `

  it('marks regular table', () => {
    const marked = markRegularTable(baseTable)
    expect(marked).toContain('class="regular-table"')
  })

  it('marks group table', () => {
    const marked = markGroupTable(baseTable)
    expect(marked).toContain('class="group-table"')
  })

  it('adds group-row id to second row of group table only', () => {
    const marked = markGroupTable(baseTable)
    const withId = addGroupRowId(marked)
    expect(withId).toContain('<tr id="group-row"><td>Group row</td></tr>')
  })

  it('mustachifies only group table rows', () => {
    const marked = addGroupRowId(markGroupTable(baseTable))
    const converted = mustachify(marked)
    expect(converted).toContain('{{#groups}}')
    expect(converted).toContain('{{/groups}}')
  })

  it('does not mustachify regular tables', () => {
    const marked = markRegularTable(baseTable)
    const converted = mustachify(marked)
    expect(converted).not.toContain('{{#groups}}')
  })

  it('demustachifies mustache group row back to <tr id="group-row">', () => {
    const mustached = `
      <table class="group-table">
        <tbody>
          <tr><th>Header</th></tr>
          {{#groups}}<tr><td>Group row</td></tr>{{/groups}}
        </tbody>
      </table>
    `
    const restored = demustachify(mustached)
    expect(restored).toContain('<tr id="group-row"><td>Group row</td></tr>')
  })
})
