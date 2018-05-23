<!-- Eventlog Modify Rec Template -->
<!-- JPRO 26/01/2006              -->

<form action="$G_LOCATION/$G_LEVEL/modify_rec" method="post">
	<input type="hidden" name="next_page_modify_rec" value="$G_LOCATION/$G_LEVEL/list_recs/$LOGNUM"></input>
	<input type="hidden" name="next_page_update_time" value="$G_LOCATION/$G_LEVEL/modify_rec/$LOGNUM/$RECNUM"></input>
 	<input type="hidden" name="next_page_remove_rec"  value="$G_LOCATION/$G_LEVEL/list_recs/$LOGNUM"></input>
	
	<input type="hidden" name="lognum" value="$LOGNUM"></input>
    <input type="hidden" name="recnum"  value="$RECNUM"></input>
	<input type="hidden" name="analyst" value="$ANALYST"></input>

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
			<input type="submit" name="CMD_update_time" value="UpdateVariables" />
		</div>
	</div>

	<div class="spacer">&nbsp;</div>
 
	$COLSS

	<div class="row">
		<div class="row-text">Comment</div>
		<div class="row-input"><textarea name="comment" cols="50" rows="10" wrap="physical">$COMMENT</textarea></div>
	</div>

	<div class="row">
		<div class="row-buttons">
			<input type="submit" name="CMD_modify_rec" value="Modify Event" />
			<input type="submit" name="CMD_remove_rec" value="Remove Event" />
		</div>
	</div>
</form>
