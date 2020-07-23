abstract class Util {

    static void test() {
        String pattern1 = "abababab"; //should return ab
        String shouldReturn1 = "ab";
        String pattern2 = "abababa"; //should return whole thing
        String shouldReturn2 = "abababa";
        String pattern3 = "ababcababc"; //should return ababc
        String shouldReturn3 = "ababc";
        String pattern4 = "1,1,0,0,1,1,0,0,1,1,0,0"; //should return 1,1,0,0
        String shouldReturn4 = "1,1,0,0";

        List<String> tests = [pattern1, pattern2, pattern3, pattern4];
        List<String> expectations = [shouldReturn1, shouldReturn2, shouldReturn3, shouldReturn4];

        int index = 0;
        for(String test in tests) {
            String result;
            if(index != 3) {
                result = getTiniestPattern(test);
            }else {
                result = getTiniestWeavingPattern(test);
            }
            print("JR NOTE: ${result == expectations[index] ? "$test passed!":"$test FAILED, got $result but expected ${expectations[index]}"}");
            index ++;
        }

    }

    //it will have commas we'll need to remove, but then add back in at the end.
    static String getTiniestWeavingPattern(String input) {
        String patternPlusComma = getTiniestPattern("$input,");
        return patternPlusComma.substring(0, patternPlusComma.length-1); //chop off trailing comma
    }
    //based on an improvement to hdalali's solution here: https://stackoverflow.com/questions/6021274/finding-shortest-repeating-cycle-in-word
    static String getTiniestPattern(String input) {
        for(int i = 0; i< input.length; i++) {
            if(i == input.length-1) {
                return input; //there is no tinier pattern, sry
            }else if(input.length % (i +1) == 0) { //the current substring is evenly divisible into the full input (any perfectly repeating pattern would do this)
                String substring = input.substring(0, i+1);
                if(confirmPatternPerfectlyRepeats(input, substring)) {
                    return substring;
                }
            }
        }
        return input;
    }

    //example input "ababcababc" , if you give it "ab" it will return false at the for loop, if you give it "ababc" it will  compare 2 parts to 10/5
    static bool confirmPatternPerfectlyRepeats(String input, String pattern) {
        List<String> substrings = input.split(pattern);
        if(substrings.length == 0) false; //why would this even be possible
        //if any of the substrings are different sizes its just not right
        for(String s in substrings) {
            if(s.length != substrings[0].length) {
                return false;
            }
        }
        //-1 cuz there will be an empty substring before the pattern
        return substrings.length-1 == input.length/pattern.length;
    }
}
