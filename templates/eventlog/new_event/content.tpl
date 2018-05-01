<!-- Eventlog New Event Template -->
<!-- JPRO 26/01/2006             -->

<form action="$G_LOCATION/$G_LEVEL/action" method="post">
	<input type="hidden" name="next_page_add_event" value="$G_LOCATION/$G_LEVEL/list_recs/$LOGNUM"></input>
	<input type="hidden" name="next_page_current_time" value="$G_LOCATION/$G_LEVEL/new_event/$LOGNUM"></input>
	<input type="hidden" name="next_page_update_time" value="$G_LOCATION/$G_LEVEL/new_event/$LOGNUM"></input>
	
	<input type="hidden" name="lognum" value="$LOGNUM"></input>

	<div class="spacer">&nbsp;</div>
	<div class="spacer">&nbsp;</div>
	
	<div class="row">
		<div class="row-text">Event Time</div>
		<div class="row-input">
			<select name="hours">
				$TIME_HOURS
			</select>
 			<select name="minutes">
				$TIME_MINUTES
			</select>
			<select name="seconds">
				$TIME_SECONDS
			</select>
			<select name="days">
				$TIME_DAYS
			</select>
			<select name="months">
				$TIME_MONTHS
			</select>
            <select name="years">
				$TIME_YEARS
			</select>
		</div>
 	</div>

	<div class="row">
		<div class="row-buttons">
			<input type="submit" name="CMD_update_time" value="Update SCS Variables" />
			<input type="submit" name="CMD_current_time" value="Set to Current Time" />
		</div>
	</div>

	<div class="spacer">&nbsp;</div>
 
	$COLSS

	<div class="row">
		<div class="row-text">Comment</div>
		<div class="row-input"><textarea name="comment" cols="50" rows="10" wrap="physical">$COMMENT</textarea></div>
	</div>

	<div class="row">
		<div class="row-buttons"><input type="submit" name="CMD_add_event" value="Add Event" />
	</div>
</form>
