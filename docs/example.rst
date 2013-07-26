
---------------
Javascript

   v("body", document, {
     "apply"  : "@import url(http://path/to/instructions.chips)",
     "render" : {my:{custom:{data:1}}},
     "display": "my.custom.data"
   })

   v("body", document, "render")
   v("body", document, "render", {my:{custom:{data:1}}})

   v("body", document, "display")
   v("body", document, "display", "my.custom.data")

   v("body", document)
     .apply("@import url(http://path/to/instructions.chips)")
     .render({my:{custom:{data:1}}})
     .display("my.custom.data")

   v(document).apply("

   @import url(http://path/to/instructions.chips);

   body {
     render: my.custom;

     render: url(http://path.to/json);
     render: url(http://path.to/json) \"my.custom\";

     render: url('http://path.to/json');
     render: url('http://path.to/json') \"my.custom\";

     render: url(\"http://path.to/json\");
     render: url(\"http://path.to/json\") \"my.custom\";

     render: url(data:application/json,{my:{custom:{data:0}}});
     render: url(data:application/json,{my:{custom:{data:0}}}) \"my.custom\";

     render: url(data:application/json;base64,e215OntjdXN0b206e2RhdGE6MH19fQ==);
     render: url(data:application/json;base64,e215OntjdXN0b206e2RhdGE6MH19fQ==) "my.custom";

     render: data({my:{custom:{data:0}}});
     render: data({my:{custom:{data:0}}}) "my.custom";

     display: !data;
   }

   ")

---------------
jQuery.goatee

jQuery("body").v({
  "apply"  : "@import url(http://path/to/instructions.chips)",
  "render" : {my:{custom:{data:1}}},
  "display": "my.custom.data"
})

jQuery("body")
  .v("apply", "@import url(http://path/to/instructions.chips)")
  .v("render", {my:{custom:{data:1}}})
  .v("display", "my.custom.data")

jQuery.v("body")
  .apply("@import url(http://path/to/instructions.chips)"),
  .render({my:{custom:{data:1}}})
  .display("my.custom.data")


---------------
Action Projection Sheets

@import url(http://path/to/instructions.aps);

body {
  render: "my.custom";

  render: url(http://path.to/json);
  render: url(http://path.to/json).match("my.custom");

  render: url('http://path.to/json');
  render: url('http://path.to/json').match("my.custom");

  render: url("http://path.to/json");
  render: url("http://path.to/json").match("my.custom");

  render: url(data:application/json,%7Bmy%3A%7Bcustom%3A%7Bdata%3A0%7D%7D%7D);
  render: url(data:application/json,%7Bmy%3A%7Bcustom%3A%7Bdata%3A0%7D%7D%7D).match("my.custom");

  render: url(data:application/json;base64,e215OntjdXN0b206e2RhdGE6MH19fQ==);
  render: url(data:application/json;base64,e215OntjdXN0b206e2RhdGE6MH19fQ==).match("my.custom");

  render: json({my:{custom:{data:0}}});
  render: json({my:{custom:{data:0}}}).select("my.custom");

  display: "!data";
}

---------------
Action Object Model

<!DOCTYPE html>
<html xmlns="…" xmlns:v="…">
 <head prefix="v:…#">
  <title>TEST</title>
  <script src="goatee.js"></script>
  <script type="application/goatee">
   /* comments are allowed ;-) */

   @import url(http://path/to/more/instructions.aps);

   nav > ul > li {
     process: json({
	title: 'Pagetitle',
	nav:[
		'home.html': {
			caption: 'Home'
		}
		'contact.html': {
			caption: 'Contact',
			children: []
		}
     	]
     });
     repeat: nav
   }

   nav > ul > li .caption {
     alter: expr(@href: this; @title: caption)
   }

   nav > ul > li .children {
     source: select("nav > ul").first()
   }

   .caption {
     content: caption
   }

  </script>
 </head>
 <body>
    <nav>
	<ul>
		<li>
			<a href="#" class="caption">Caption</span>
                        <span class="children"></span>
		</li>
	</ul>
    </nav>
 </body>
</html>


