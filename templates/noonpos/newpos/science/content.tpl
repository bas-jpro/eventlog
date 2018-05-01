<!-- Noonpos Newpos Science Template -->
<!-- JPRO 13/01/2008                 -->

<form action="$G_LOCATION/$G_LEVEL/newpos/science" method="post">
	<input type="hidden" name="next_page_newpos" value="$G_LOCATION/$G_LEVEL/showpos/science" />
	<input type="hidden" name="next_page_newpos_addloc" value="$G_LOCATION/$G_LEVEL/addloc/transit" />
	<input type="hidden" name="next_page_reset" value="$G_LOCATION/$G_LEVEL/newpos/science" />

	<input type="hidden" name="type" value="science" />

	$OVERWRITE_MESSAGES	
	$ERROR_MESSAGES 

	<div class="row">
		<div class="rem-block0">
			Information
		</div>
	
		<div class="rem-block1">
			Cruise
			<select name="bridgelog_id" tabindex=0 >
				$BRIDGELOG_IDSS
			</select>
		</div>
	</div>

	<div class="row">
		<div class="pos-block">
			Position
			<br />
			<div class="right">
				Absolute
				<br />
				Relative to
			</div>
		</div>

		<div class="pos-block">
			<span class="$LAT_ERROR">Latitude</span>
			
			<br />
			<input type="text" name="lat_deg" size="2" value="$LAT_DEG" tabindex=1 />&deg;
			<input type="text" name="lat_min" size="3" value="$LAT_MIN" tabindex=2 />'
			<select name="lat_dir" tabindex=3 >
				$LAT_DIRS
			</select>
			
			<br />
			<select name="bearing_relative_id" style="width: 250px" tabindex=7 >
				$BEARING_RELATIVE_IDS
			</select>
		</div>

		<div class="pos-block">
			<span class="$LON_ERROR">Longitude</span>

			<br />
			<input type="text" name="lon_deg" size="3" value="$LON_DEG" tabindex=4 />&deg;
			<input type="text" name="lon_min" size="3" value="$LON_MIN" tabindex=5 />'
			<select name="lon_dir" tabindex=6 >
				$LON_DIRS
			</select>

			<br />
			<span class="$BEARING_TRUE_ERROR">
				<input type="text" name="bearing_true" size="3" value="$BEARING_TRUE" tabindex=8 />&deg;T</span> x
			<span class="$BEARING_DIST_ERROR"><input type="text" name="bearing_dist" size="3" value="$BEARING_DIST" tabindex=9 />'</span>
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
            <input type="text" name="distance" size="3" value="$DISTANCE" tabindex=10 />'

            <br />
            <span class="$TOTAL_DISTANCE_ERROR">Total Run</span>

            <br />
            <input type="text" name="total_distance" size="4" value="$TOTAL_DISTANCE" tabindex=13 />'
        </div>

        <div class="ts-block">
            Steaming Time

            <br />
            <input type="text" name="steam_time" size="3" value="$STEAM_TIME" tabindex=11 /> hrs

            <br />
            Total Steam Time

            <br />
            <input type="text" name="total_steam_time" size="4" value="$TOTAL_STEAM_TIME" tabindex=14 /> hrs
        </div>

        <div class="ts-block">
            Average Speed

            <br />
            <input type="text" name="avg_spd" size="3" value="$AVG_SPD" tabindex=12 /> kts

            <br />
            Total Avg Speed

            <br />
            <input type="text" name="total_avg_spd" size="3" value="$TOTAL_AVG_SPD" tabindex=15 /> kts
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
			<select name="wind_dir" tabindex=16 >
				$WIND_DIRS
			</select>
			<select name="wind_force" tabindex=17 >
				$WIND_FORCES
			</select>

			<br />
			Pressure
	
			<br />
			<input type="text" name="pressure" size="6" value="$PRESSURE" tabindex=21 />
		</div>

		<div class="wx-block1">
			Sea State

			<br />
			<select name="sea_state" tabindex=18 >
				$SEA_STATES
			</select>

			<br />
			Tendency (3 hrs)
			
			<br />
			<select name="tendancy" tabindex=22>
				$TENDANCYS
			</select>
		</div>

		<div class="wx-block1">
			Air Temp

			<br />
			<input type="text" name="air_temp" size="3" value="$AIR_TEMP" tabindex=19 >&deg;C

			<br />
			Time Zone (GMT Offset)

			<br />
			<select name="timezone" tabindex=23>
				$TIMEZONES
			</select>
		</div>

		<div class="wx-block1">
			Sea Temp

			<br />
			<input type="text" name="sea_temp" size="3" value="$SEA_TEMP" tabindex=20 >&deg;C

			<br />
			&nbsp;

			<br />
			&nbsp;
		</div>
	</div>

	<div class="spacer">&nbsp;</div>

	<div class="row">
		<div class="rem-block0">
			General Remarks
		</div>

		<div class="rem-block1">
			<textarea name="remarks" rows="8" cols="80" wrap="physical" tabindex=24>$REMARKS</textarea>
		</div>
	</div>

	<div class="spacer">&nbsp;</div>

	<div class="row">
		<div class="rem-block0">
			<input type="submit" name="CMD_reset" value="Reset" tabindex=25 />
		</div>

		<div class="rem-block1">
			<div class="right">
				<input type="submit" name="CMD_newpos_addloc" value="Add Location" tabindex=26 />
				&nbsp;&nbsp;&nbsp;
				Click this button when finished
				<input type="submit" name="CMD_newpos" value="OK" tabindex=27 />
			</div>
		</div>
	</div>

	<br />
</form>

