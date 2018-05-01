<!-- Noonpos Add Location Template -->
<!-- JPRO 06/02/2006               -->

$LOCSS

<div id="loc-form">
	<form action="$G_LOCATION/$G_LEVEL/addloc/$TYPE" method="post">
		<input type="hidden" name="next_page_add_location" value="$G_LOCATION/$G_LEVEL/newpos/$TYPE" />

		New Location: <input type="text" size="40" name="new_location" value="$NEW_LOCATION" />
		&nbsp; &nbsp;
		<input type="submit" name="CMD_add_location" value="Add Location" />	
	</form>
</div>
