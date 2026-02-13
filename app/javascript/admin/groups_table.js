/**
 * Converts each <table class="group-table"> by wrapping the second <tr> with {{#groups}}...{{/groups}}.
 * Leaves all other tables untouched.
 */
export function mustachify(html) {
  return html.replace(
    /<table[^>]*class=["'][^"']*group-table[^"']*["'][^>]*>([\s\S]*?)<\/table>/g,
    (match, content) => {
      return match.replace(
        /(<tbody>[\s\S]*?<tr[^>]*>[\s\S]*?<\/tr>\s*)(<tr[^>]*>[\s\S]*?<\/tr>)/,
        (_, header, groupRow) => `${header}{{#groups}}${groupRow}{{/groups}}`
      );
    }
  );
}

/**
 * Converts Mustache-wrapped rows inside <table class="group-table"> back to <tr id="group-row">.
 */
export function demustachify(html) {
  return html.replace(
    /<table[^>]*class=["'][^"']*group-table[^"']*["'][^>]*>([\s\S]*?)<\/table>/g,
    (match, content) => {
      const unwrapped = content.replace(
        /{{#groups}}\s*(<tr[^>]*>[\s\S]*?<\/tr>)\s*{{\/groups}}/,
        (_, row) => row.replace('<tr', '<tr id="group-row"')
      );
      return match.replace(content, unwrapped);
    }
  );
}
/**
 * Adds id="group-row" to the second <tr> inside a <tbody> for every table.
 * Use this after inserting a group table to prepare for Mustache wrapping.
 */
export function addGroupRowId(html) {
  return html.replace(/<table[^>]*class="[^"]*group-table[^"]*"[^>]*>[\s\S]*?<\/table>/g, table => {
    return table.replace(
      /(<tbody>[\s\S]*?<tr[^>]*>[\s\S]*?<\/tr>\s*)<tr(?![^>]*id=["']group-row["'])/i,
      '$1<tr id="group-row"'
    );
  });
}

/**
 * Adds class="regular-table" to the first <table> that doesn't already have
 * class="group-table" or "regular-table".
 */
export function markRegularTable(html) {
  return html.replace(
    /<table((?![^>]*\b(?:regular|group)-table\b)[^>]*)>/,
    (match, attrs) => {
      return match.includes('class=')
        ? match.replace(/class=(["'])([^"']*)\1/, 'class=$1$2 regular-table$1')
        : `<table class="regular-table"${attrs}>`;
    }
  );
}

/**
 * Adds class="group-table" to the first <table> that doesn't already have
 * class="group-table" or "regular-table".
 */
export function markGroupTable(html) {
  return html.replace(
    /<table((?![^>]*\b(?:regular|group)-table\b)[^>]*)>/,
    (match, attrs) => {
      return match.includes('class=')
        ? match.replace(/class=(["'])([^"']*)\1/, 'class=$1$2 group-table$1')
        : `<table class="group-table"${attrs}>`;
    }
  );
}
