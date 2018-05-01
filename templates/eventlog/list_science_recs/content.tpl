<!-- Sciencelog list recs template -->
<!-- JPRO 31/01/2006               -->

<div id="title">$TITLE | $NAME</div>

<form action="$G_LOCATION/$G_LEVEL/list_science_recs" method="post" />
	<input type="hidden" name="next_page_xfer_noonpos" value="/noonpos/bridge/newpos/science" />

	<input type="hidden" name="lognum" value="$LOGNUM" />

	<div id="mark-button">
		<input type="submit" name="CMD_xfer_noonpos" value="Export to Noon Pos" />
	</div>

	<table>
		<thead>
			<tr id="hdr2">
				<th class="last_time">Time</th>
				<th class="sciencecol">Event</th>
				<th class="sciencecol">Lat</th>
				<th class="sciencecol">Lon</th>
				<th class="sciencecom">Comment</th>
				<th class="user">User</th>
				<th class="mark">&nbsp;</th>
			</tr>
		</thead>
	
		<tbody>
			$VALSS
		</tbody>
	</table>
</form>	
