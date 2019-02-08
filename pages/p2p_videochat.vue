<template>
  <div>
    <v-card class="mx-2 my-2">
      <v-form>
        <v-container>
          <v-layout
            row
            wrap
          >
            <v-flex
              xs12
              sm12
              md12
            >
              <v-text-field
                v-model="peerId"
                label="Peer ID"
                :readonly="true"
              />
            </v-flex>
            <v-flex
              xs12
              sm12
              md6
            >
              <v-select
                v-model="selectedAudio"
                :items="audios"
                label="オーディオ"
                @change="changeAudioVideo"
              />
            </v-flex>
            <v-flex
              xs12
              sm12
              md6
            >
              <v-select
                v-model="selectedVideo"
                :items="videos"
                label="ビデオ"
                @change="changeAudioVideo"
              />
            </v-flex>
          </v-layout>
        </v-container>
      </v-form>
    </v-card>
    <v-card class="mx-2 my-2">
      <v-form ref="form" @submit.prevent="makeCall">
        <v-container>
          <v-layout
            row
            wrap
          >
            <v-flex
              xs12
              sm12
              md12
            >
              接続先のPeer IDを入力して接続してください。
            </v-flex>
            <v-flex
              xs12
              sm12
              md12
            >
              <v-text-field
                v-model="callPeerId"
                label="Call Peer ID"
              />
            </v-flex>
          </v-layout>
        </v-container>
        <v-card-actions>
          <v-spacer />
          <v-btn color="primary" type="submit">
            接続
          </v-btn>
          <v-btn @click="endCall">切断</v-btn>
        </v-card-actions>
      </v-form>
    </v-card>
    <v-layout
      row
      wrap
    >
      <v-flex
        xs12
        sm12
        md6
      >
        <v-card class="mx-2 my-2">
          <video id="their-video" class="video" autoplay playsinline />
        </v-card>
      </v-flex>
      <v-flex
        xs12
        sm12
        md6
      >
        <v-card class="mx-2 my-2">
          <video id="my-video" class="video" muted="true" autoplay playsinline />
        </v-card>
      </v-flex>
    </v-layout>
  </div>
</template>

<script>
/* eslint-disable no-console */
import Peer from 'skyway-js'

export default {
  data() {
    return {
      peer: null,
      selectedAudio: '',
      selectedVideo: '',
      audios: [],
      videos: [],
      localStream: null,
      peerId: '',
      callPeerId: '',
      call: null
    }
  },
  mounted() {
    // Peerオブジェクトの作成
    this.peer = new Peer({ key: process.env.API_KEY, debug: 3 })

    // 接続成功・失敗・切断時のイベント設定
    this.peer.on('open', () => {
      console.log(`peer event open: peer.id=${this.peer.id}`)
      this.peerId = this.peer.id
    })
    this.peer.on('error', err => {
      console.error(`peer event error:`, err)
    })
    this.peer.on('disconnected', () => {
      console.log(`peer event disconnected`)
    })

    // 着信のイベント設定
    this.peer.on('call', call => {
      console.log(`peer event call`)
      call.answer(this.localStream)
      this.connectCall(call)
    })

    // オーディオ・ビデオデバイスの取得
    navigator.mediaDevices.enumerateDevices().then(deviceInfos => {
      for (let i = 0; i !== deviceInfos.length; ++i) {
        const deviceInfo = deviceInfos[i]
        if (deviceInfo.kind === 'audioinput') {
          this.audios.push({
            text: deviceInfo.label || `Microphone ${this.audios.length + 1}`,
            value: deviceInfo.deviceId
          })
        } else if (deviceInfo.kind === 'videoinput') {
          this.videos.push({
            text: deviceInfo.label || `Camera  ${this.videos.length - 1}`,
            value: deviceInfo.deviceId
          })
        }
      }
    })
  },
  methods: {
    // オーディオ・ビデオの変更
    changeAudioVideo: function() {
      this.$nextTick(() => {
        console.log('changeAudioVideo')
        console.log(this.selectedAudio)
        console.log(this.selectedVideo)
        if (this.selectedAudio !== '' && this.selectedVideo !== '') {
          console.log('true')
          this.connectLocalCamera()
        }
      })
    },
    // ローカルカメラに接続する
    connectLocalCamera: async function() {
      const options = {
        audio: this.selectedAudio
          ? { deviceId: { exact: this.selectedAudio } }
          : false,
        video: this.selectedVideo
          ? { deviceId: { exact: this.selectedVideo } }
          : false
      }

      const stream = await navigator.mediaDevices.getUserMedia(options)
      document.getElementById('my-video').srcObject = stream
      this.localStream = stream
    },
    // 発信
    makeCall: function() {
      const call = this.peer.call(this.callPeerId, this.localStream)
      this.connectCall(call)
    },
    // 接続
    connectCall: function(call) {
      this.endCall()
      call.on('stream', stream => {
        const el = document.getElementById('their-video')
        el.srcObject = stream
        el.play()
      })
      this.call = call
    },
    // 切断
    endCall: function() {
      if (this.call) {
        this.call.close()
        this.call = null
      }
    }
  }
}
/* eslint-enable no-console */
</script>

<style lang='scss' scoped>
.video {
  width: 100%;
  height: 100%;
}
</style>
