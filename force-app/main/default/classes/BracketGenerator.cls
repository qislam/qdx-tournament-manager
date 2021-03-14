public with sharing class BracketGenerator {
    public static Integer numberOfLoops = 1;

    @AuraEnabled
    public static String generate(String tournamentName, List<String> participants) {
        Tournament obj = run(tournamentName, participants);
        return JSON.serialize(obj);
    }

    public static Tournament run(String tournamentName, List<String> participants) {
        Tournament tournament = new Tournament();
        tournament.name = tournamentName;
        tournament.rounds = new List<Round>();

        Boolean makeRounds = true;
        while(makeRounds) {
            Round round = new Round();
            round.matches = new List<Match>();
            round.name = tournament.name + '_Round-' + String.valueOf(tournament.rounds.size()+1);

            QDX_Log.debug(round.name);

            if (tournament.rounds.isEmpty()) {
                String[] participantsCopy = participants.clone();
                Util.randomize(participantsCopy);

                Integer matchNumber = 1;
                while(!participantsCopy.isEmpty()) {
                    Match match = new Match();
                    match.name = round.name + '_Match-' + matchNumber;
                    match.opponent1 = participantsCopy.remove(0);
                    if (participantsCopy.isEmpty()) {
                        match.winner = match.opponent1;
                    } else {
                        match.opponent2 = participantsCopy.remove(0);
                    }
                    round.matches.add(match);
                    matchNumber += 1;
                }
            } else {
                Round previousRound = tournament.rounds[tournament.rounds.size() - 1];
                List<Match> prevMatches = previousRound.matches.clone();
                Util.randomize(prevMatches);
                
                Integer matchNumber = 1;
                while(!prevMatches.isEmpty()) {
                    Match match = new Match();
                    match.name = round.name + '_Match-' + matchNumber;
                    match.opponent1 = (prevMatches.remove(0)).name;
                    if (prevMatches.isEmpty()) {
                        match.winner = match.opponent1;
                    } else {
                        match.opponent2 = (prevMatches.remove(0)).name;
                    }
                    round.matches.add(match);
                    matchNumber += 1;
                }
            }
            
            QDX_Log.debug('Round generated: ' + round);

            tournament.rounds.add(round);
            if (round.matches.size() == 1) makeRounds = false;
        }
        
        QDX_Log.publish();
        return tournament;
    }
    
    public class LogException extends exception{}

    public class Tournament {
        public String name;
        public List<Round> rounds;
    }

    public class Round {
        public String name;
        public List<Match> matches;
    }

    public class Match {
        public String name;
        public String opponent1;
        public String opponent2;
        public String winner;
    }
}