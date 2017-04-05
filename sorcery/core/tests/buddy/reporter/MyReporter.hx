package sorcery.core.tests.buddy.reporter;
import buddy.reporting.TraceReporter.Color;
import haxe.CallStack.StackItem;

import buddy.BuddySuite.Spec;
import buddy.BuddySuite.Suite;
import buddy.reporting.ConsoleColorReporter;
import buddy.reporting.ConsoleReporter;
import haxe.CallStack.StackItem;
import promhx.Deferred;
import promhx.Promise;

import buddy.BuddySuite.Spec;
import buddy.BuddySuite.Suite;
import buddy.BuddySuite.SpecStatus;

using Lambda;
using StringTools;
#if flash
typedef Out = MyFlashReportPrinter;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class MyReporter extends ConsoleReporter
{

	public function new(colors=false)
	{
		super(colors);

	}

	override public function progress(spec:Spec)
	{
		var status = switch (spec.status)
		{
			case Failed: '#FF0000">Failed';
			case Passed: '"#00FF00">Passed';
			case Pending: '"#0000FF">Pending';
			case Unknown: '"#FFFFFF">Unknown';
		}
		status = '<bold><font color="$status</font></bold>';
		progressString += status;
		return resolveImmediately(spec);
	}

	override public function done(suites:Iterable<Suite>, status:Bool)
	{
		#if (js && !nodejs && !travix)
		// Skip newline, already printed in console.log()
		#else
		println("");
		#end

		var total = 0;
		var failures = 0;
		var pending = 0;

		var countTests : Suite -> Void = null;
		var printTests : Suite -> Int -> Void = null;

		countTests = function(s : Suite)
		{
			if (s.error != null) failures++; // Count a crashed BuddySuite as a failure?

			for (sp in s.steps) switch sp
			{
				case TSpec(sp):
						total++;
						if (sp.status == Failed) failures++;
						else if (sp.status == Pending) pending++;
					case TSuite(s):
						countTests(s);
				}
		};

		suites.iter(countTests);

		printTests = function(s : Suite, indentLevel : Int)
		{
			//function print(str : String, color : Color = Default)
			//{
				//var start = strCol(color), end = strCol(Default);
				//println(start + str.lpad(" ", str.length + Std.int(Math.max(0, indentLevel * 2))) + end);
			//}

			function printStack(indent : String, stack : Array<StackItem>)
			{
				if (stack == null || stack.length == 0) return;
				for (s in stack) switch s
				{
					case FilePos(_, file, line) if (line > 0 && file.indexOf("buddy/internal/") != 0 && file.indexOf("buddy.SuitesRunner") != 0):
							print(indent + '@ $file:$line');
						case _:
					}
			}

			function printTraces(spec : Spec)
			{
				for (t in spec.traces) print("    " + t);
			}

			if (s.description.length > 0) print(s.description);

			if (s.error != null)
			{
				// The whole suite crashed.
				print("ERROR: " + s.error);
				printStack('  ', s.stack);
				return;
			}

			for (step in s.steps) switch step
			{
				case TSpec(sp):
						if (sp.status == Failed)
						{
							print(toColor("  " + sp.description + "(FAILED)", "FF0000"));

							for (failure in sp.failures)
							{
								print("    " + failure.error);
								printStack('      ', failure.stack);
							}
						}
						else {
							print("  " + sp.description + toColor(sp.status.getName(), sp.status == Passed ? "008800" : "EEBB00"));
						}
						printTraces(sp);
					case TSuite(s):
						printTests(s, indentLevel + 1);
				}
		};
		
		suites.iter(printTests.bind(_, -1));

		var totalColor = if (failures > 0) Red else Green;
		var pendingColor = if (pending > 0) Yellow else totalColor;

		println('$total specs, ${failures > 0 ? toColor(failures + " failures", "FF0000") :"0 failures"} $pending pending');
		

		return resolveImmediately(suites);
	}
		
	function toColor(str:String, color:String)
	{
		return '<bold><font color="#$color">$str</font></bold>';
	}
	
	override function print(s:String)
	{
		Out.print(s);
	}

	override function println(s:String)
	{
		Out.println(s);
	}

}
#else
typedef MyReporter = ConsoleColorReporter;
#end