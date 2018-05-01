<!-- Noonpos Newpos Transit Template -->
<!-- JPRO 01/02/2006                 -->

<form action="$G_LOCATION/$G_LEVEL/newpos/transit" method="post">
	<input type="hidden" name="next_page_newpos" value="$G_LOCATION/$G_LEVEL/showpos/transit" />
	<input type="hidden" name="next_page_newpos_addloc" value="$G_LOCATION/$G_LEVEL/addloc/transit" />
	<input type="hidden" name="next_page_reset" value="$G_LOCATION/$G_LEVEL/newpos/transit" />
	
	<input type="hidden" name="type" value="transit" />

	$OVERWRITE_MESSAGES
	$ERROR_MESSAGES 

	<div class="row">
		<div class="pos-block">
			Position
			<br />
			<div class="right">
				Absolute
				<br />
				Relative to
				<br />
				<span class="$CMG_ERROR">Course Made Good</span>
			</div>
		</div>

		<div class="pos-block">
			<span class="$LAT_ERROR">Latitude</span>
			
			<br />
			<input type="text" name="lat_deg" size="2" value="$LAT_DEG" tabIndex=0 />&deg;
			<input type="text" name="lat_min" size="3" value="$LAT_MIN" tabIndex=1 />'
			<select name="lat_dir" tabIndex=2 >
				$LAT_DIRS
			</select>
			
			<br />
			<select name="bearing_relative_id" style="width: 250px" tabIndex=6>
				$BEARING_RELATIVE_IDS
			</select>
	
			<br />
			<input type="text" name="cmg" size="2" value="$CMG" tabIndex=9/>&deg;T
		</div>

		<div class="pos-block">
			<span class="$LON_ERROR">Longitude</span>

			<br />
			<input type="text" name="lon_deg" size="3" value="$LON_DEG" tabIndex=3 />&deg;
			<input type="text" name="lon_min" size="3" value="$LON_MIN" tabIndex=4 />'
			<select name="lon_dir" tabIndex=5>
				$LON_DIRS
			</select>

			<br />
			<span class="$BEARING_TRUE_ERROR">
				<input type="text" name="bearing_true" size="3" value="$BEARING_TRUE" tabIndex=7/>&deg;T x
			</span>
			<span class="$BEARING_DIST_ERROR"><input type="text" name="bearing_dist" size="3" value="$BEARING_DIST" tabIndex=8/>'</span>

			<br />
			&nbsp;
		</div>
	</div>

	<div class="spacer">&nbsp;</div>

	<div class="row">
		<div class="ts-block">
			Time & Speed
		</div>
		
		<div class="ts-block">
			<span class="$DISTANCE_ERROR">Day's Run</span>

			<br />
			<input type="text" name="distance" size="3" value="$DISTANCE" tabIndex=10 />'
			
			<br />
			<span class="$TOTAL_DISTANCE_ERROR">Total Run</span>

			<br />
			<input type="text" name="total_distance" size="4" value="$TOTAL_DISTANCE" tabIndex=13 />'
		</div>

		<div class="ts-block">
			Steaming Time

			<br />
			<input type="text" name="steam_time" size="3" value="$STEAM_TIME" tabIndex=11 /> hrs
		
			<br />
			Total Steam Time
			
			<br />
			<input type="text" name="total_steam_time" size="4" value="$TOTAL_STEAM_TIME" tabIndex=14 /> hrs
		</div>

		<div class="ts-block">
			Average Speed

			<br />
			<input type="text" name="avg_spd" size="3" value="$AVG_SPD" tabIndex=12 /> kts

			<br />
			Total Avg Speed

			<br />
			<input type="text" name="total_avg_spd" size="3" value="$TOTAL_AVG_SPD" tabIndex=15 /> kts
		</div>
	</div>

	<div class="spacer">&nbsp;</div>

	<div class="row">
		<div class="eta-block0">
			ETA
		</div>

		<div class="eta-block1">
			ETA Destination 1
			
			<br />
			<select name="dest1_id" style="width: 240px" tabIndex=16 >
				$DEST1_IDS
			</select>

			<br />
			ETA Destination 2
		
			<br />
			<select name="dest2_id" style="width: 240px" tabIndex=24>
				$DEST2_IDS
			</select>
		</div>

		<div class="eta-block2">
			time
			<select name="eta1_time_hour" tabIndex=17 >
				$ETA1_TIME_HOURS
			</select> :
			<select name="eta1_time_minute" tabIndex=18 >
				$ETA1_TIME_MINUTES
			</select>
			<input type="hidden" name="eta1_time_second" value="0" />

			<br />
			date
			<select name="eta1_date_day" tabIndex=19>
				$ETA1_DATE_DAYS
			</select>
			<select name="eta1_date_month" style="width: 7em" tabIndex=20>
				$ETA1_DATE_MONTHS
			</select>
			<select name="eta1_date_year" tabIndex=21>
				$ETA1_DATE_YEARS
			</select>

			<br />
			time
			<select name="eta2_time_hour" tabIndex=25>
				$ETA2_TIME_HOURS
			</select> :
			<select name="eta2_time_minute" tabIndex=26>
				$ETA2_TIME_MINUTES
			</select>
			<input type="hidden" name="eta2_time_second" value="0" />

			<br />
			date
			<select name="eta2_date_day" tabIndex=27 >
				$ETA2_DATE_DAYS
			</select>
			<select name="eta2_date_month" style="width: 7em" tabIndex=28 >
				$ETA2_DATE_MONTHS
			</select>
			<select name="eta2_date_year" tabIndex=29 >
				$ETA2_DATE_YEARS
			</select>
		</div>

		<div class="eta-block3">
			@
			<input type="text" name="eta1_spd" size="3" value="$ETA1_SPD" tabIndex=23/> kts
	
			<br />
			&nbsp;

			<br />
			@			
			<input type="text" name="eta2_spd" size="3" value="$ETA2_SPD" tabIndex=30 /> kts

			<br />
			&nbsp;
		</div>
	</div>

	<div class="spacer">&nbsp;</div>

	<div class="row">
		<div class="wx-block0">
			Weather
		</div>

		<div class="wx-block1">
			Wind
			
			<br />
			<select name="wind_dir" tabIndex=31 >
				$WIND_DIRS
			</select>
			<select name="wind_force" tabIndex=32 >
				$WIND_FORCES
			</select>

			<br />
			Pressure
	
			<br />
			<input type="text" name="pressure" size="6" value="$PRESSURE" tabIndex=36/>
		</div>

		<div class="wx-block1">
			Sea State

			<br />
			<select name="sea_state" tabIndex=33 >
				$SEA_STATES
			</select>

			<br />
			Tendency (3 hrs)
			
			<br />
			<select name="tendancy" tabIndex=37>
				$TENDANCYS
			</select>
		</div>

		<div class="wx-block1">
			Air Temp

			<br />
			<input type="text" name="air_temp" size="3" value="$AIR_TEMP" tabIndex=34>&deg;C

			<br />
			Time Zone (GMT Offset)

			<br />
			<select name="timezone" tabIndex=38>
				$TIMEZONES
			</select>
		</div>

		<div class="wx-block1">
			Sea Temp

			<br />
			<input type="text" name="sea_temp" size="3" value="$SEA_TEMP" tabIndex=35>&deg;C

			<br />
			&nbsp;

			<br />
			&nbsp;
		</div>
	</div>

	<div class="spacer">&nbsp;</div>

	<div class="row">
		<div class="rem-block0">
			Remarks
		</div>

		<div class="rem-block1">
			<textarea name="remarks" rows="4" cols="80" wrap="physical" tabIndex=39>$REMARKS</textarea>
		</div>
	</div>

	<div class="spacer">&nbsp;</div>

	<div class="row">
		<div class="rem-block0">
			<input type="submit" name="CMD_reset" value="Reset" tabIndex=40 />
		</div>

		<div class="rem-block1">
			<div class="right">
				<input type="submit" name="CMD_newpos_addloc" value="Add Location" tabIndex=41 />
				&nbsp;&nbsp;&nbsp;
				Click this button when finished
				<input type="submit" name="CMD_newpos" value="OK" tabIndex=42 />
			</div>
		</div>
	</div>

	<br />
</form>

