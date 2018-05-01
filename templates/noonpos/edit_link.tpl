<!-- Noon Pos Edit Link -->
<!-- JPRO 04/02/2006    -->

<div id="nextprev">
	<a href="$G_LOCATION/$G_LEVEL/showpos/$PREV_TYPE/$PREV_DATE">$PREV_LINK</a>
	&nbsp;&nbsp;&nbsp;
	<a href="$G_LOCATION/$G_LEVEL/showpos/$NEXT_TYPE/$NEXT_DATE">$NEXT_LINK</a>
</div>

<div id="edit-link">
	<form action="$G_LOCATION/bridge/newpos/$POSTYPE" method="post">
		<input type="submit" name="edit_link" value="Add New Position" />
	</form>
</div>

