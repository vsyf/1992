#!/usr/bin/env sh

commit() {
	year=$1
	month=$2
	day=$3
	GIT_AUTHOR_DATE="${year}-${month}-${day}T18:00:00" \
		GIT_COMMITTER_DATE="${year}-${month}-${day}T18:00:00" \
		git commit --allow-empty -m "Commited on ${year}-${month}-${day}T18:00:00"
}

push_year() {
	year=$1
	last_year=$2

	# push last year commit to github
	if [ -n "$last_year" ]; then
		git checkout "main"
		git merge "$last_year-commit" --allow-unrelated-histories
		git push -u origin "main" -f
	fi

	# create new branch
	if [ "$year" != "$last_year" ]; then
		git checkout -b "$year-commit"
	fi
}

_() {
	read -p "Start Data（YYYY-MM-DD）: " start_date
	read -p "End Data（YYYY-MM-DD）: " end_date

	start_date=$(date -d "$start_date" +%Y-%m-%d)
	end_date=$(date -d "$end_date" +%Y-%m-%d)

	# start_data or end_data is empty, exit
	if [ -z "$start_date" ] || [ -z "$end_date" ]; then
		echo "start date or end date format error"
		exit 1
	fi

	# if end_date < start_date, exit
	if [ "$end_date" \< "$start_date" ]; then
		echo "end date must be greater than start date"
		exit 1
	fi

	echo "commit from $start_date to $end_date"

	current_date="$start_date"
	current_year=""

	touch README.md
	git init
	git add README.md
	git commit -m "docs: touch README.md"
	git branch -M main
	git push -u origin main -f

	# contains end_data, so add one day
	end_date=$(date -d "$end_date + 1 day" +%Y-%m-%d)

	while [ "$current_date" != "$end_date" ]; do
		year=$(date -d "$current_date" +%Y)
		month=$(date -d "$current_date" +%m)
		day=$(date -d "$current_date" +%d)

		if [ "$year" != "$current_year" ]; then
			push_year "$year" "$current_year"
			current_year="$year"
		fi

		commit "$year" "$month" "$day"
		current_date=$(date -d "$current_date + 1 day" +%Y-%m-%d)
	done

	push_year "$year" "$current_year"

} && _

unset -f _
