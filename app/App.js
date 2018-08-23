import React from 'react'
import {
  AragonApp,
  Button,
  Text,
  CircleGraph,

  observe
} from '@aragon/ui'
import Aragon, { providers } from '@aragon/client'
import styled from 'styled-components'

const AppContainer = styled(AragonApp)`
  display: flex;
  align-items: center;
  justify-content: center;
`

export default class App extends React.Component {
  render () {
    return (
      <AppContainer>
        <div style={{ textAlign: 'center' }}>
          <ObservedBallot observable={this.props.observable} />
          <ObservedCount observable={this.props.observable} />
          <Button onClick={() => this.props.app.decrement(1)}>Decrement</Button>
          <Button onClick={() => this.props.app.increment(1)}>Increment</Button>
        </div>
      </AppContainer>
    )
  }
}

const ObservedBallot = observe(
  (state$) => state$,
  { ballotName: 'Should this vote pass?' }
)(
  ({ ballotName }) => <Text.Block style={{ textAlign: 'center' }} size='xxlarge'>{ballotName}</Text.Block>
)

const ObservedCount = observe(
  (state$) => state$,
  { count: 0 }
)(
  ({ count }) => <div style={{ margin: '20px' }}><CircleGraph value={count/3} /></div>
)
