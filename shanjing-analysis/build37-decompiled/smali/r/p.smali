.class public final synthetic Lr/p;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lr/q;

.field public final synthetic e:Lr/m;


# direct methods
.method public synthetic constructor <init>(Lr/q;Lr/m;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lr/p;->d:Lr/q;

    iput-object p2, p0, Lr/p;->e:Lr/m;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 2

    iget-object v0, p0, Lr/p;->d:Lr/q;

    iget-object v1, p0, Lr/p;->e:Lr/m;

    invoke-static {v0, v1}, Lr/q;->d(Lr/q;Lr/m;)V

    return-void
.end method
