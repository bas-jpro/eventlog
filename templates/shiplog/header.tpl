<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<!-- Shiplog Header Template -->
<!-- $Id$                    -->

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
	<meta http-equiv="$REFRESH" content="60" />
    <base href="http://$G_HOSTNAME/" />
    <link rel="stylesheet" type="text/css" href="/css/shiplog.css" />
	<link rel="stylesheet" type="text/css" href="/css/jquery.datetimepicker.css" />
	<title>James Clark Ross Operations</title>
  </head>
  
  <body>
	<div id="header">
	  <div class="header-left"><em>RRS James Clark Ross</em></div>
	  <div class="header-center">ALL TIMES ARE LOCAL (GMT $GMT_OFFSET)</div>
	  <div class="header-right">$UPDATE_TIME</div>
	</div>
	
	<div id="content">
	  $CONTENT
	</div>

	$FOOTER
