<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<!-- Noonpos Header Template -->
<!-- JPRO 01/02/2006         -->

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
        <head>
                <base href="http://$G_HOSTNAME/" />
                <link rel="stylesheet" type="text/css" href="/css/noonpos.css" />
				<script src="/js/table-utils.js" type="text/javascript"></script>
                <title>James Clark Ross Noon Position</title>
        </head>

        <body onload="oddeven_rows()">
			<div id="header">
				<img src="/images/header.jpg" alt="[RRS JCR Noon Position]" />

				<div id="date">
					$HEADER_DATE
					<span id="hdr_time">$HEADER_TIME</span>
	
					$INCLUDE_POS_TYPE
				</div>
			</div>
					
			<div id="content">
				$CONTENT
	
				$INCLUDE_EDIT_LINK
			</div>

			$FOOTER
