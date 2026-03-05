.class public final synthetic Lio/flutter/plugin/platform/v;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lio/flutter/plugin/platform/w$a;

.field public final synthetic e:Lio/flutter/plugin/platform/a0;

.field public final synthetic f:F

.field public final synthetic g:Li0/l$b;


# direct methods
.method public synthetic constructor <init>(Lio/flutter/plugin/platform/w$a;Lio/flutter/plugin/platform/a0;FLi0/l$b;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lio/flutter/plugin/platform/v;->d:Lio/flutter/plugin/platform/w$a;

    iput-object p2, p0, Lio/flutter/plugin/platform/v;->e:Lio/flutter/plugin/platform/a0;

    iput p3, p0, Lio/flutter/plugin/platform/v;->f:F

    iput-object p4, p0, Lio/flutter/plugin/platform/v;->g:Li0/l$b;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 4

    iget-object v0, p0, Lio/flutter/plugin/platform/v;->d:Lio/flutter/plugin/platform/w$a;

    iget-object v1, p0, Lio/flutter/plugin/platform/v;->e:Lio/flutter/plugin/platform/a0;

    iget v2, p0, Lio/flutter/plugin/platform/v;->f:F

    iget-object v3, p0, Lio/flutter/plugin/platform/v;->g:Li0/l$b;

    invoke-static {v0, v1, v2, v3}, Lio/flutter/plugin/platform/w$a;->j(Lio/flutter/plugin/platform/w$a;Lio/flutter/plugin/platform/a0;FLi0/l$b;)V

    return-void
.end method
