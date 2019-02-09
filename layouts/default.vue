<template>
  <v-app light>
    <v-navigation-drawer
      v-model="drawer"
      :mini-variant="miniVariant"
      :clipped="clipped"
      fixed
      app
    >
      <v-list>
        <v-list-tile
          v-for="(item, i) in items"
          :key="i"
          :to="item.to"
          router
          exact
        >
          <v-list-tile-action>
            <v-icon>{{ item.icon }}</v-icon>
          </v-list-tile-action>
          <v-list-tile-content>
            <v-list-tile-title v-text="item.title" />
          </v-list-tile-content>
        </v-list-tile>
      </v-list>
    </v-navigation-drawer>
    <v-toolbar
      :clipped-left="clipped"
      fixed
      app
    >
      <v-toolbar-side-icon @click="drawer = !drawer" />
      <v-toolbar-title v-text="title" />
    </v-toolbar>
    <v-content>
      <v-container>
        <nuxt />
      </v-container>
    </v-content>
    <v-footer
      :fixed="fixed"
      app
    />
  </v-app>
</template>

<script>
export default {
  data() {
    return {
      clipped: true,
      drawer: false,
      fixed: false,
      items: [
        {
          icon: 'home',
          title: 'ホーム',
          to: '/'
        },
        {
          icon: 'voice_chat',
          title: 'ビデオ通話(1対1,P2P)',
          to: '/p2p_videochat'
        },
        {
          icon: 'voice_chat',
          title: 'ビデオ通話(多人数,P2P)',
          to: '/fullmesh_videochat'
        },
        {
          icon: 'voice_chat',
          title: 'ビデオ配信(1対多,P2P)',
          to: '/p2p_broadcast'
        }
      ],
      miniVariant: false,
      right: true,
      rightDrawer: false,
      title: 'SkyWayサンプル'
    }
  }
}
</script>
