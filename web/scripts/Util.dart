abstract class Util {

    static void test() {
        String pattern4 = "1,1,0,0,1,1,0,0,1,1,0,0"; //should return 1,1,0,0
        String shouldReturn4 = "1,1,0,0";
        String pattern5 = "1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0";
        String shouldReturn5 = "1,1,0,0";
        String pattern6 = "1,1,0,0,1,1,0,0,1,1,0"; //should return 1,1,0,0
        String shouldReturn6 = "1,1,0,0";

        List<String> tests = [pattern4, pattern5, pattern6];
        List<String> expectations = [
            shouldReturn4,
            shouldReturn5,
            shouldReturn6
        ];

        int index = 0;
        print("tests are $tests");
        for (String test in tests) {
            String result;
            result = getTiniestWeavingPattern(test);
            print("JR NOTE: ${result == expectations[index]
                ? "$test passed!"
                : "$test FAILED, got $result but expected ${expectations[index]}"}");
            index ++;
        }
    }

    static int numTimesIntIsInPattern(String pattern, int goal) {
        return intListFromPattern(pattern).where((int i) => i == goal).length;
    }

    //it will have commas we'll need to remove, but then add back in at the end.
    static String getTiniestWeavingPattern(String input) {
        List<int> int_pattern = intListFromPattern(input);
        int interval = find_interval(int_pattern);
        return int_pattern.sublist(0,interval).join(",");
    }

    static List<int> intListFromPattern(String input) => new List.from(input.split(",").map((String s) => int.parse(s)));

    static int getTiniestWeavingPatternLength(String input) {
        List<int> int_pattern = intListFromPattern(input);
        int interval = find_interval(int_pattern);
        return interval;
    }


    //dilletantMathematician to the rescue, this is converted from javascript

    static bool repeats_at(List<int>array, int interval)
    {
        for (var i=interval; i<array.length; i++) {
            if (array[i%interval] != array[i]) {
                return false;
            }
        }
        return true;
    }

    static int find_interval(array)
    {
        int i=1;
        for (; i<array.length; i++) {
            if (repeats_at(array,i)) {
                return i;
            }
        }
        return i;
    }



}