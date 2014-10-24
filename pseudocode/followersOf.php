<?php
	
	// get chain
	
	// load xml
	
	$maxNbSuggestions=10;
	
	$exprIds = new Array(/* get expr length */);
	for (/* each wd in dico */) {
		for (/* each exprIds */) {
			if (/* this $exprIds == null */) {
				if (/* expression fits with this wd */) {
					$exprIds = /* this dico id */;
				}
			}
		}
	}
	
	$suggestions = Array();
	
	for ($curExprLen = /* get expr length */ ; $curExprLen > 0 && count($suggestions)<=$maxNbSuggestions ; $curExprLen--) {
		for (/* each st */) {
			if (/* fits with the expression */) {
				// make an array of results
				while (count($suggestions)<=$maxNbSuggestions) {
					// find the most occuring follower from the results
					// add it to the suggestions
					// remove it from the results
				}
			}
		}
	}
	
	// if nothing found, search for a word completion ?
	
	// return the list of suggestions
	
?>