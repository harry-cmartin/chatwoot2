import { frontendURL } from '../../../helper/URLHelper';
import PromptPage from './PromptPage.vue';
import SavedPromptsList from './SavedPromptsList.vue';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/prompts'),
      name: 'saved_prompts_list',
      component: SavedPromptsList,
      meta: {
        permissions: ['administrator', 'agent', 'custom_role'],
      },
    },
    {
      path: frontendURL('accounts/:accountId/prompt'),
      name: 'prompt_page',
      component: PromptPage,
      meta: {
        permissions: ['administrator', 'agent', 'custom_role'],
      },
    },
  ],
};