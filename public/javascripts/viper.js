var viper = {
	resizeTextArea: function(textarea, collapsed) {
		var lines = textarea.value.split("\n");
	    var count = lines.length;
	    lines.each(function(line) { count += parseInt(line.length / 70); });
	
	    var rows = parseInt(collapsed / 20);
	
	    if (count > rows) {
			textarea.style.height = (collapsed * 2) + 'px';
	    }
	
	    if (count <= rows) {
			textarea.style.height = collapsed + 'px';
	    }
	}
}
