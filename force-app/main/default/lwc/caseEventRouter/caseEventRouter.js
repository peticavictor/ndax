import { LightningElement, api } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { openTab } from 'lightning/platformWorkspaceApi';
import Id from '@salesforce/user/Id';

export default class CaseEventRouter extends LightningElement {
    @api eventChannel = '/event/New_Phone_Case__e';
    @api caseIdField = 'Case_Id__c';
    @api ownerIdField = 'Owner_Id__c';
    @api replayId = -1;
    @api autoFocus;

    subscription = null;

    connectedCallback() {
        this.init();
    }

    disconnectedCallback() {
        if (this.subscription) {
            unsubscribe(this.subscription, () => {});
            this.subscription = null;
        }
    }

    async init() {
        try {
            const msgCallback = this.handleEvent.bind(this);

            subscribe(this.eventChannel, this.replayId, msgCallback)
                .then((response) => {
                    this.subscription = response;
                })
                .catch((e) => {
                    this.logError(e);
                });
        } catch (e) {
            this.logError(e);
        }
    }

    async handleEvent(message) {
        try {
            const payload = message?.data?.payload || {};
            const caseId = payload[this.caseIdField];
            const ownerId = payload[this.ownerIdField];

            if (!caseId) {
                this.log('No CaseId found in payload field: ' + this.caseIdField);
                return;
            }

            if (!ownerId) {
                this.log('No OwnerId found in payload field: ' + this.ownerIdField);
                return;
            }

            if (ownerId !== Id) {
                return;
            }

            await openTab({
                recordId: caseId,
                focus: this.autoFocus
            });
        } catch (e) {
            this.logError(e);
        }
    }

    log(msg) {
        console.log('[CaseEventRouter]', msg);
    }

    logError(e) {
        console.error('[CaseEventRouter]', e);
    }
}