<!-- Sciencelog Modify Rec Template -->
<!-- JPRO 31/01/2006                -->

<form action="$G_LOCATION/$G_LEVEL/modify_science_rec/$LOGNUM/$ID" method="post">
	<input type="hidden" name="next_page_modify_science_rec" value="$G_LOCATION/$G_LEVEL/list_science_recs/$LOGNUM" />
	<input type="hidden" name="next_page_modify_science_update_time" value="$G_LOCATION/$G_LEVEL/modify_science_rec/$LOGNUM/$ID" />
    <input type="hidden" name="next_page_modify_science_current_time" value="$G_LOCATION/$G_LEVEL/modify_science_rec/$LOGNUM/$ID" />
	<input type="hidden" name="lognum" value="$LOGNUM" />
	<input type="hidden" name="id" value="$ID" />

	<div class="spacer">&nbsp;</div>
	<div class="spacer">&nbsp;</div>

	<div class="row">
		<div class="row-text">Event Time</div>
		<div class="row-input">
			<select name="time_hour">$TIME_HOURS</select> : 
			<select name="time_minute"> $TIME_MINUTES </select> &nbsp; &nbsp;
<!--        <select name="time_second">  </select> --> <input type="hidden" name="time_second" value="0" />

            <select name="time_day">$TIME_DAYS</select> / 
			<select name="time_month">$TIME_MONTHS</select> /
            <select name="time_year">$TIME_YEARS</select>
		</div>
	</div>
                                                                                
	<div class="row">
		<div class="row-buttons">
 			<input type="submit" name="CMD_modify_science_update_time" value="Update SCS Variables" />
			<input type="submit" name="CMD_modify_science_current_time" value="Set to Current Time" />
		</div>
	</div>

	<div class="spacer">&nbsp;</div>

	<div class="row">
		<div class="row-text">Event Number</div>
		<div class="row-input"><input type="text" name="event_no" value="$EVENT_NO" size="40" /></div>
	</div>

	<div class="row">
		<div class="row-text">Latitude</div>
		<div class="row-input"><input type="text" name="lat" value="$LAT" size="40" /></div>
	</div>

	<div class="row">
		<div class="row-text">Longitude</div>
		<div class="row-input">
			<input type="text" name="lon" value="$LON" size="40" />
		</div>
	</div>
	
	<div class="row">
		<div class="row-text">Comment</div>
		<div class="row-input"><input type="text" name="comment" value="$COMMENT" size="80" /></div>
	</div>

	<div class="spacer">&nbsp;</div>

	<div class="row">
		<div class="row-buttons"><input type="submit" name="CMD_modify_science_rec" value="Modify Event" /></div>
	</div>
</form>

