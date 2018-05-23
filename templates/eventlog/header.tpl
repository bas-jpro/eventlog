<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<!-- Eventlog 5 Header Template -->
<!-- JPRO 26/01/2006            -->

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
        <head>
                <base href="http://$G_HOSTNAME/" />
                <link rel="stylesheet" type="text/css" href="/css/$G_CSS_FILE" />
				<script src="/js/table-utils.js" type="text/javascript"></script>
                <title>Eventlog | $G_ANALYST_USER</title>
        </head>

        <body onload="oddeven_rows()">

			<div id="sidebar">
				$INCLUDE_SIDEBAR
			</div>
		
			<div id="content">
				$INCLUDE_BUTTONS

				$CONTENT
			</div>

			$FOOTER
