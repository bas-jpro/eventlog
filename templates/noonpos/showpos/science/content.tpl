<!-- Show Noon Position (science) -->
<!-- JPRO 05/02/2006              -->

<div id="showpos">
	<table>
		<tbody>
			<tr>
				<td>Latitude:</td>
				<td>$LAT</td>
			</tr>
			<tr>
				<td>Longitude:</td>
				<td>$LON</td>
			</tr>
			<tr>
				<td>Bearing:</td>
				<td>$BEARING_TRUE &deg;T, $BEARING_DIST Nm from $BEARING_RELATIVE_ID</td>
			</tr>
			<tr>
				<td>Cruise Number:</td>
				<td>$BRIDGELOG_ID_NAME</td>
			</tr>
<!--
			<tr>
				<td>Destination:</td>
				<td>$DEST1_ID</td>
			</tr>
			<tr>
				<td>ETA at $ETA1_SPD knots is</td>
				<td>ETA1_TIME_HOUR:ETA1_TIME_MINUTE on ETA1_DATE_DAY ETA1_DATE_MONTH_NAME ETA1_DATE_YEAR</td>
			</tr>
-->
			<tr>

				<td>Distance Travelled:</td>
				<td>$DISTANCE</td>
			</tr>
			<tr>
				<td>Total Distance Travelled:</td>
				<td>$TOTAL_DISTANCE</td>
			</tr>
            <tr>
                <td>Steam Time:</td>
                <td>$STEAM_TIME</td>
            </tr>
            <tr>
                <td>Total Steam Time:</td>
                <td>$TOTAL_STEAM_TIME</td>
            </tr>
            <tr>
                <td>Average Speed:</td>
                <td>$AVG_SPD</td>
            </tr>
            <tr>
                <td>Total Average Speed:</td>
                <td>$TOTAL_AVG_SPD</td>
            </tr>
			<tr>
				<td>Wind:</td>
				<td>Direction $WIND_DIR, Force $WIND_FORCE</td>
			</tr>
			<tr>
				<td>Sea State:</td>
				<td>$SEA_STATE</td>
			</tr>
			<tr>
				<td>Air Temp: $AIR_TEMP &deg;C</td>
				<td>Sea Temp: $SEA_TEMP &deg;C</td>
			</tr>
			<tr>
				<td>Pressure: $PRESSURE</td>
				<td>Tendency (3hrs): $TENDANCY</td>
			</tr>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr>
				<td colspan="2">General Remarks</td>
			</tr>
			<tr>
				<td colspan="2" class="remarks">$REMARKS</td>
			</tr>
		</tbody>
	</table>
</div>

