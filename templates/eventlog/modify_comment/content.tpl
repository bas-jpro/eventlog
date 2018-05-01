<!-- Comment Modify template -->
<!-- JPRO 31/01/2006         -->

<form action="$G_LOCATION/$G_LEVEL/action" method="post">
	<input type="hidden" name="next_page_modify_comment" value="$G_LOCATION/$G_LEVEL/list_comments/$LOGNUM" />
	<input type="hidden" name="next_page_remove_comment" value="$G_LOCATION/$G_LEVEL/list_comments/$LOGNUM" />
	<input type="hidden" name="next_page_current_time" value="$G_LOCATION/$G_LEVEL/modify_comment/$LOGNUM/$COMMENT_NUM" />

	<input type="hidden" name="lognum" value="$LOGNUM" />
    <input type="hidden" name="comment_num" value="$COMMENT_NUM" />
    <input type="hidden" name="analyst" value="$ANALYST" />

	<div class="spacer">&nbsp;</div>
	<div class="spacer">&nbsp;</div>

	<div class="row">
		<div class="row-text">Comment Time</div>
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
		<div class="row-input"><textarea name="comment" rows=10 cols=50 wrap="physical">$COMMENT</textarea></div>
	</div>

	<div class="row">
		<div class="row-buttons">
			<input type="submit" name="CMD_modify_comment" value="Modify Comment" />
			<input type="submit" name="CMD_remove_comment" value="Remove Comment" />
		</div>	
	</div>

</form>

