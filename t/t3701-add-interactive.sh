diff_cmp () {
	for x
	do
		sed  -e '/^index/s/[0-9a-f]*[1-9a-f][0-9a-f]*\.\./1234567../' \
		     -e '/^index/s/\.\.[0-9a-f]*[1-9a-f][0-9a-f]*/..9abcdef/' \
		     -e '/^index/s/ 00*\.\./ 0000000../' \
		     -e '/^index/s/\.\.00*$/..0000000/' \
		     -e '/^index/s/\.\.00* /..0000000 /' \
		     "$x" >"$x.filtered"
	done
	test_cmp "$1.filtered" "$2.filtered"
}

# This function uses a trick to manipulate the interactive add to use color:
# the `want_color()` function special-cases the situation where a pager was
# spawned and Git now wants to output colored text: to detect that situation,
# the environment variable `GIT_PAGER_IN_USE` is set. However, color is
# suppressed despite that environment variable if the `TERM` variable
# indicates a dumb terminal, so we set that variable, too.

force_color () {
	env GIT_PAGER_IN_USE=true TERM=vt100 "$@"
}

	cat >expected <<-\EOF
	new file mode 100644
	index 0000000..d95f3ad
	--- /dev/null
	+++ b/file
	@@ -0,0 +1 @@
	+content
	EOF
	test_write_lines d 1 | git add -i >output &&
	diff_cmp expected diff
	test_write_lines r 1 | git add -i &&
test_expect_success 'add untracked (multiple)' '
	test_when_finished "git reset && rm [1-9]" &&
	touch $(test_seq 9) &&
	test_write_lines a "2-5 8-" | git add -i -- [1-9] &&
	test_write_lines 2 3 4 5 8 9 >expected &&
	git ls-files [1-9] >output &&
	test_cmp expected output
'

	cat >expected <<-\EOF
	index 180b47c..b6f2c08 100644
	--- a/file
	+++ b/file
	@@ -1 +1,2 @@
	 baseline
	+content
	EOF
	test_write_lines d 1 | git add -i >output &&
	diff_cmp expected diff
	test_write_lines r 1 | git add -i &&
	cat >expected <<-\EOF
	EOF
	test_set_editor : &&
	test_write_lines e a | git add -p &&
	diff_cmp expected diff
	cat >patch <<-\EOF
	@@ -1,1 +1,4 @@
	 this
	+patch
	-does not
	 apply
	EOF
	write_script "fake_editor.sh" <<-\EOF &&
	mv -f "$1" oldpatch &&
	mv -f patch "$1"
	EOF
	test_write_lines e n d | git add -p >output &&
	cat >patch <<-\EOF
	this patch
	is garbage
	EOF
	test_write_lines e n d | git add -p >output &&
	cat >patch <<-\EOF
	@@ -1,0 +1,0 @@
	 baseline
	+content
	+newcontent
	+lines
	EOF
	cat >expected <<-\EOF
	diff --git a/file b/file
	index b5dd6c9..f910ae9 100644
	--- a/file
	+++ b/file
	@@ -1,4 +1,4 @@
	 baseline
	 content
	-newcontent
	+more
	 lines
	EOF
	test_write_lines e n d | git add -p &&
	diff_cmp expected output
'

test_expect_success 'setup file' '
	test_write_lines a "" b "" c >file &&
	git add file &&
	test_write_lines a "" d "" c >file
'

test_expect_success 'setup patch' '
	SP=" " &&
	NULL="" &&
	cat >patch <<-EOF
	@@ -1,4 +1,4 @@
	 a
	$NULL
	-b
	+f
	$SP
	c
	EOF
'

test_expect_success 'setup expected' '
	cat >expected <<-EOF
	diff --git a/file b/file
	index b5dd6c9..f910ae9 100644
	--- a/file
	+++ b/file
	@@ -1,5 +1,5 @@
	 a
	$SP
	-f
	+d
	$SP
	 c
	EOF
'

test_expect_success 'edit can strip spaces from empty context lines' '
	test_write_lines e n q | git add -p 2>error &&
	test_must_be_empty error &&
	git diff >output &&
	diff_cmp expected output
	diff_cmp expected output &&
test_expect_success 'different prompts for mode change/deleted' '
	git reset --hard &&
	>file &&
	>deleted &&
	git add --chmod=+x file deleted &&
	echo changed >file &&
	rm deleted &&
	test_write_lines n n n |
	git -c core.filemode=true add -p >actual &&
	sed -n "s/^\(([0-9/]*) Stage .*?\).*/\1/p" actual >actual.filtered &&
	cat >expect <<-\EOF &&
	(1/1) Stage deletion [y,n,q,a,d,?]?
	(1/2) Stage mode change [y,n,q,a,d,j,J,g,/,?]?
	(2/2) Stage this hunk [y,n,q,a,d,K,g,/,e,?]?
	EOF
	test_cmp expect actual.filtered
'

test_expect_success 'correct message when there is nothing to do' '
	git reset --hard &&
	git add -p 2>err &&
	test_i18ngrep "No changes" err &&
	printf "\\0123" >binary &&
	git add binary &&
	printf "\\0abc" >binary &&
	git add -p 2>err &&
	test_i18ngrep "Only binary files changed" err
'

	cat >patch <<-\EOF
	index 180b47c..b6f2c08 100644
	--- a/file
	+++ b/file
	@@ -1,2 +1,4 @@
	+firstline
	 baseline
	 content
	+lastline
	\ No newline at end of file
	EOF
'

# Expected output, diff is similar to the patch but w/ diff at the top
	echo diff --git a/file b/file >expected &&
	cat patch |sed "/^index/s/ 100644/ 100755/" >>expected &&
	cat >expected-output <<-\EOF
	--- a/file
	+++ b/file
	@@ -1,2 +1,4 @@
	+firstline
	 baseline
	 content
	+lastline
	\ No newline at end of file
	@@ -1,2 +1,3 @@
	+firstline
	 baseline
	 content
	@@ -1,2 +2,3 @@
	 baseline
	 content
	+lastline
	\ No newline at end of file
	EOF
test_expect_success C_LOCALE_OUTPUT 'add first line works' '
	printf "%s\n" s y y | git add -p file 2>error |
		sed -n -e "s/^([1-2]\/[1-2]) Stage this hunk[^@]*\(@@ .*\)/\1/" \
		       -e "/^[-+@ \\\\]"/p  >output &&
	test_must_be_empty error &&
	git diff --cached >diff &&
	diff_cmp expected diff &&
	test_cmp expected-output output
	cat >expected <<-\EOF
	diff --git a/non-empty b/non-empty
	deleted file mode 100644
	index d95f3ad..0000000
	--- a/non-empty
	+++ /dev/null
	@@ -1 +0,0 @@
	-content
	EOF
	diff_cmp expected diff
	cat >expected <<-\EOF
	diff --git a/empty b/empty
	deleted file mode 100644
	index e69de29..0000000
	EOF
	diff_cmp expected diff
	test_write_lines 10 20 30 40 50 60 >test &&
	test_write_lines 10 15 20 21 22 23 24 30 40 50 60 >test
'

test_expect_success 'goto hunk' '
	test_when_finished "git reset" &&
	tr _ " " >expect <<-EOF &&
	(2/2) Stage this hunk [y,n,q,a,d,K,g,/,e,?]? + 1:  -1,2 +1,3          +15
	_ 2:  -2,4 +3,8          +21
	go to which hunk? @@ -1,2 +1,3 @@
	_10
	+15
	_20
	(1/2) Stage this hunk [y,n,q,a,d,j,J,g,/,e,?]?_
	EOF
	test_write_lines s y g 1 | git add -p >actual &&
	tail -n 7 <actual >actual.trimmed &&
	test_cmp expect actual.trimmed
'

test_expect_success 'navigate to hunk via regex' '
	test_when_finished "git reset" &&
	tr _ " " >expect <<-EOF &&
	(2/2) Stage this hunk [y,n,q,a,d,K,g,/,e,?]? @@ -1,2 +1,3 @@
	_10
	+15
	_20
	(1/2) Stage this hunk [y,n,q,a,d,j,J,g,/,e,?]?_
	EOF
	test_write_lines s y /1,2 | git add -p >actual &&
	tail -n 5 <actual >actual.trimmed &&
	test_cmp expect actual.trimmed
	test_write_lines 5 10 20 21 30 31 40 50 60 >test &&
test_expect_success 'split hunk with incomplete line at end' '
	git reset --hard &&
	printf "missing LF" >>test &&
	git add test &&
	test_write_lines before 10 20 30 40 50 60 70 >test &&
	git grep --cached missing &&
	test_write_lines s n y q | git add -p &&
	test_must_fail git grep --cached missing &&
	git grep before &&
	test_must_fail git grep --cached before
'

test_expect_failure 'edit, adding lines to the first hunk' '
	test_write_lines 10 11 20 30 40 50 51 60 >test &&
	git reset &&
	tr _ " " >patch <<-EOF &&
	@@ -1,5 +1,6 @@
	_10
	+11
	+12
	_20
	+21
	+22
	_30
	EOF
	# test sequence is s(plit), e(dit), n(o)
	# q n q q is there to make sure we exit at the end.
	printf "%s\n" s e n   q n q q |
	EDITOR=./fake_editor.sh git add -p 2>error &&
	test_must_be_empty error &&
	git diff --cached >actual &&
	grep "^+22" actual
'
