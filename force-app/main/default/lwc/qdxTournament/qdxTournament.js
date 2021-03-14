import { LightningElement } from 'lwc';
import generateTournament from '@salesforce/apex/BracketGenerator.generate';

export default class QdxTournament extends LightningElement {
    participants = [];
    tournament;

    handleParticipantsInput(event) {
        this.participants = event.target.value.split(',');
        console.log('Participants: ' + JSON.stringify(this.participants));

        generateTournament({
            tournamentName: 'Test',
            participants: this.participants
        }).then(
            result => {
                console.log('Result from server: ' + result);
                this.tournament = result;
            }
        ).catch(
            error => console.log('Error: ' + error)
        )
    }
}