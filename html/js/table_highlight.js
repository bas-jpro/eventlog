/* Alternate Highlight rows of a given table */
/* $Id$ */

function highlight_table(id) {
	if (!document.getElementById) return;

	var body = document.getElementById(id);
	if (!id) return;

	var rows = body.rows;
	if (!rows) return;

	for (var r=0; r<rows.length; r++) {
		if (r % 2) {
			rows[r].className = rows[r].className + " odd";
		} else {
			rows[r].className = rows[r].className + " even";
		}
	}
}
