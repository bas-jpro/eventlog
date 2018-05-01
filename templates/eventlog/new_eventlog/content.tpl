<!-- Eventlog New Eventlog -->
<!-- JPRO 26/01/2006       -->

<form action="$G_LOCATION/$G_LEVEL/new_eventlog" method="post">
	<input type="hidden" name="next_page_add_column" value="$G_LOCATION/$G_LEVEL/new_eventlog" />
	<input type="hidden" name="next_page_del_column" value="$G_LOCATION/$G_LEVEL/new_eventlog" />
	<input type="hidden" name="next_page_create_log" value="$G_LOCATION/$G_LEVEL/view_logs" />

	<input type="hidden" name="num_cols" value="$NUM_COLS" />

	<div id="entry-form">
		<div class="edit-row">
			<div>Name</div>
			<input class="edit-row-input" type="text" name="name" value="$NAME" />
		</div>

		<div class="edit-row">
			<div>Science log</div>
			<select name="sciencelog">
				$SCIENCELOGSS
			</select>
		</div>

		$COLSS
		
		<div class="reset">&nbsp;</div>
	
		<div class="edit-row">
			<div>&nbsp;</div>	
			<input class="edit-row-submit" type="submit" name="CMD_add_column" value="Add Column"></input>
			<input class="edit-row-submit" type="submit" name="CMD_del_column" value="Remove Column(s)"></input>
		</div>

		<div class="edit-row">
			<div>&nbsp;</div>
			<input class="edit-row-submit" type="submit" name="CMD_create_log" value="Create Eventlog"></input>
		</div>
	</div>
</form>

<div class="eventlog-note">
Please note a time field and a comment field is automatically created for each eventlog.
</div>

