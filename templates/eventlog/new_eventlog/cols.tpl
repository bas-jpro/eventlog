<!-- New Eventlog Columns -->
<!-- JPRO 02/12/2003  -->


<div class="log-col">
	<div class="col-title">Column $COLS_COUNT</div>
	<div class="log-col-row">
		<div>Column Variable</div>
		<select name="col_$COLS_NUM">
				$COLS_STREAMSS
		</select>
	</div>
	<div class="log-col-row">
		<div>Column Title</div>
		<input type="text" size="20" name="col_desc_$COLS_NUM" value="$COLS_DESC"></input>
	</div>
	<div class="log-col-row">
		<div>Remove Column</div>
		<input type="checkbox" class="chkbox" name="col_del_$COLS_NUM" value="Yes"></input>
	</div>
</div>
