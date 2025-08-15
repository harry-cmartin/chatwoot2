import { frontendURL } from '../../../helper/URLHelper';
import RagPage from './RagPage.vue';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/rag'),
      name: 'rag_page',
      component: RagPage,
      meta: {
        permissions: ['administrator', 'agent', 'custom_role'],
      },
    },
  ],
};