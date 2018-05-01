<!-- Eventlog New Sciencelog -->
<!-- JPRO 31/01/2006         -->

<div class="spacer">&nbsp;</div>
<div id="title">Create New Bridge Science Log</div>
<div class="spacer">&nbsp;</div>
<div class="spacer">&nbsp;</div>

<form action="$G_LOCATION/$G_LEVEL/new_sciencelog" method="post">
	<input type="hidden" name="next_page_new_sciencelog" value="$G_LOCATION/$G_LEVEL/view_science_logs" />

	$ERROR_MESSAGES

	<div class="edit-row">
		<div class="$TITLE_ERROR">Cruise Title</div>
		<input type="string" size="60" name="title" value="$TITLE" />
	</div>

	<div class="edit-row">
		<div class="$NAME_ERROR">Cruise Name</div>
		<input type="string" size="60" name="name" value="$NAME" />
	</div>

	<div class="edit-row">
		<div class="$PSO_ERROR">PSO</div>
		<input type="string" size="60" name="pso" value="$PSO" />
	</div>

	<div class="edit-row">
		<div class="$INSTITUTE_ERROR">Institute</div>
		<input type="string" size="60" name="institute" value="$INSTITUTE" />
	</div>

	<div class="edit-row">
		<div class="$START_DATE_ERROR">Start Date</div>
		<select name="start_date_day">   $START_DATE_DAYS   </select>
		<select name="start_date_month"> $START_DATE_MONTHS </select>
		<select name="start_date_year">  $START_DATE_YEARS  </select>
	</div>

	<div class="edit-row">
		<div class="$END_DATE_ERROR">End Date</div>
		<select name="end_date_day">   $END_DATE_DAYS   </select>
		<select name="end_date_month"> $END_DATE_MONTHS </select>
		<select name="end_date_year">  $END_DATE_YEARS  </select>
	</div>

	<div class="spacer">&nbsp;</div>

	<div class="edit-row">
		<div>&nbsp;</div>
		<input type="submit" name="CMD_new_sciencelog" value="Create Sciencelog" />
	</div>
</form>
