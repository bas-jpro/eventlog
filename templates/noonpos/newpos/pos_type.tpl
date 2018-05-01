<!-- Noonpos Newpos Position Type -->
<!-- JPRO 01/02/2006              -->

<div id="postype">
	<form action="$G_LOCATION/$G_LEVEL/newpos" method="post">
		<input type="hidden" name="next_page_sel_transit" value="$G_LOCATION/$G_LEVEL/newpos/transit" />
		<input type="hidden" name="next_page_sel_science" value="$G_LOCATION/$G_LEVEL/newpos/science" />

		<input type="submit" id="$TRANSIT_ACTIVE" name="CMD_sel_transit" value="Transit" tabindex=100 />
		<input type="submit" id="$SCIENCE_ACTIVE" name="CMD_sel_science" value="Science" tabindex=101 />
	</form>
</div>
