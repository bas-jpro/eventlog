<!-- Comment add template -->
<!-- JPRO 31/01/2006      -->

<form action="$G_LOCATION/$G_LEVEL/action" method="post">
	<input type="hidden" name="next_page_add_comment" value="$G_LOCATION/$G_LEVEL/list_comments/$LOGNUM" />
	<input type="hidden" name="next_page_current_time" value="$G_LOCATION/$G_LEVEL/new_comment/$LOGNUM" />

	<input type="hidden" name="lognum" value="$LOGNUM" />

	<div class="spacer">&nbsp;</div>
	<div class="spacer">&nbsp;</div>

	<div class="row">
		<div class="row-text">CommentTime</div>
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
		<div class="row-buttons"><input type="submit" name="CMD_current_time" value="Set to Current Time" /></div>
	</div>

	<div class="spacer">&nbsp;</div>

	<div class="row">
		<div class="row-text">Comment</div>
		<div class="row-input"><textarea name="comment" rows=10 cols=50 wrap="physical"></textarea></div>
	</div>

	<div class="row">
		<div class="row-buttons"><input type="submit" name="CMD_add_comment" value="Add Comment" /></div>
	</div>

</form>

