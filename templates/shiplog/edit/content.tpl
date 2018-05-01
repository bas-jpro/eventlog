<!-- Shiplog edit content -->
<!-- $Id -->

<div id="add-event">
	$ERROR_MESSAGES

	<!-- Tabs -->
	<!-- Taken from http://callmenick.com/post/simple-tabbed-content-area-with-css-and-jquery -->
	<ul id="tabs">
		<li class="$EVENT_ACTIVE_TAB">Events</li>
		<li class="$GENERAL_ACTIVE_TAB">General Remarks</li>
		<li class="$TZ_ACTIVE_TAB">Timezone changes</li>
	</ul>

	<!-- Tab contents -->
	<ul id="tab">

		<!-- Add/Modify Events -->
		<li class="$EVENT_ACTIVE_TAB">
			<form action="$G_LOCATION/$G_LEVEL/edit" method="POST">
				  <input type="hidden" name="next_page_add_event" value="$G_LOCATION/$G_LEVEL/edit" />
				  <input type="hidden" name="type" value="event" />
				  <input type="hidden" name="id" value="$ID" />
			
				<div class="config25">
					 <span><font class="$START_TIME_ERROR">Start Time</font></span>
					 <br />
					 <input type="text" name="start_time" class="picker_class" value="$START_TIME" required />
				</div>

				<div class="config65">
					 <span><font class="$DESCRIPTION_ERROR">Description</font></span>
					 <br />
					 <input type="text" name="description" value="$DESCRIPTION" required />
				</div>

				<div class="config10">
					 <span><font class="$EVENT_TYPE_ERROR">Type</font></span>
					 <br />
					 <select name="event_type">
					 	$EVENT_TYPES
					 </select>
				</div>
				
				<div class="reset"></div>
				
				<div class="config-btn">
			 		 <input type="submit" name="CMD_add_event" value="$EDIT Event" />
				</div>
			</form>
		</li>

		<!-- General remarks -->
		<li class="$GENERAL_ACTIVE_TAB">
			<form action="$G_LOCATION/$G_LEVEL/edit" method="POST">
				<input type="hidden" name="next_page_add_general" value="$G_LOCATION/$G_LEVEL/edit" />
				<input type="hidden" name="type" value="general" />
				<input type="hidden" name="event_type" value="ship" />
				<input type="hidden" name="id" value="$ID_GENERAL" />
				
				<div class="config100">
					 <span><font class="$GENERAL_DESCRIPTION_ERROR">Description</font></span>
					 <br />
					 <textarea name="description_general" rows="5" cols="60" wrap="hard" required>$DESCRIPTION_GENERAL</textarea>
				</div>

				<div class="config-btn">
					 <input type="submit" name="CMD_add_general" value="$EDIT_GENERAL Event" />
				</div>
			</form>
		</li>

		<!-- Timezone Changes -->
		<li class="$TZ_ACTIVE_TAB">
			<form action="$G_LOCATION/$G_LEVEL/edit" method="POST">
				<input type="hidden" name="next_page_add_tz_change" value="$G_LOCATION/$G_LEVEL/edit" />
				<input type="hidden" name="type" value="tz_change" />
				<input type="hidden" name="event_type" value="ship" />
				<input type="hidden" name="id" value="$ID_TZ" />
			
				<div class="config25">
					<span><font class="$START_TIME_TZ_ERROR">Start Time</font></span>
					<br />
					<input type="text" name="start_time_tz" class="picker_class" value="$START_TIME_TZ" required />
				</div>

				<div class="config25">
				 	<span>New GMT Offset</span>
				 	<br />
				 	<select name="gmt_offset" required>
				 	 	$GMT_OFFSETS
				 	</select>
				</div>

				<div class="reset"></div>

				<div class="config-btn">
					<input type="submit" name="CMD_add_tz_change" value="$EDIT_TZ TZ Change" />
				</div>
			</form>
		</li>
	</ul>
</div>

<div class="reset"></div>

<form action="$G_LOCATION/$G_LEVEL/edit" method="POST">
	<input type="hidden" name="next_page_del_events" value="$G_LOCATION/$G_LEVEL/edit" />
	
	<table id="events">
		<thead>
			<tr id="hdr1">
				<th class="start_date">Start Date/Time</th>
				<th class="desc">Description</th>
				<th class="dup">Dup</th>
				<th class="del">Del</th>
			</tr>
		</thead>

		<tbody id="events_body">
			$EVENTSS

			<tr>
				<th colspan="4">General Remarks</th>
			</tr>

			$GENERALS
		</tbody>

		<tfoot>
			<tr class="config-btn">
				<td colspan="3">
					<input type="submit" name="CMD_del_events" value="Delete events" />
				</td>
			</tr>
		</tfoot>
	</table>
</form>

<!-- Date/Timepicker JS -->
<script src="/js/jquery.js"></script>
<script src="/js/jquery.datetimepicker.full.min.js"></script>

<script>
$.datetimepicker.setLocale('en');

$('.picker_class').datetimepicker();

$('.day_picker_class').datetimepicker({ timepicker: false, format: 'Y/m/d' });

</script>

<!-- Highlight table -->
<script src="/js/table_highlight.js"></script>
<script>
highlight_table("events_body");
</script>

<!-- Tabs -->
<script>
$(document).ready(function(){
    $("ul#tabs li").click(function(e){
        if (!$(this).hasClass("active")) {
            var tabNum = $(this).index();
            var nthChild = tabNum+1;
            $("ul#tabs li.active").removeClass("active");
            $(this).addClass("active");
            $("ul#tab li.active").removeClass("active");
            $("ul#tab li:nth-child("+nthChild+")").addClass("active");
        }
    });
});
</script>
